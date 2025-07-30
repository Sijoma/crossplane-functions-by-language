package main

import (
	"context"
	"encoding/json"
	"fmt"

	"github.com/crossplane/function-sdk-go/logging"
	fnv1 "github.com/crossplane/function-sdk-go/proto/v1"
	"github.com/crossplane/function-sdk-go/request"
	"github.com/crossplane/function-sdk-go/resource"
	"github.com/crossplane/function-sdk-go/resource/composed"
	"github.com/crossplane/function-sdk-go/response"
	"k8s.io/utils/ptr"

	v1 "dev.upbound.io/models/io/k8s/meta/v1"
	"dev.upbound.io/models/io/sijoma/v1alpha1"
	"dev.upbound.io/models/io/upbound/gcp/kms/v1beta2"
)

// Function is your composition function.
type Function struct {
	fnv1.UnimplementedFunctionRunnerServiceServer

	log logging.Logger
}

// RunFunction runs the Function.
func (f *Function) RunFunction(_ context.Context, req *fnv1.RunFunctionRequest) (*fnv1.RunFunctionResponse, error) {
	f.log.Info("Running function", "tag", req.GetMeta().GetTag())

	rsp := response.To(req, response.DefaultTTL)

	observedComposite, err := request.GetObservedCompositeResource(req)
	if err != nil {
		response.Fatal(rsp, fmt.Errorf("cannot get XR %w", err))
		return rsp, nil
	}

	observedComposed, err := request.GetObservedComposedResources(req)
	if err != nil {
		response.Fatal(rsp, fmt.Errorf("cannot get observed resources: %w", err))
		return rsp, nil
	}

	var xr v1alpha1.XEncryptionKey
	if err := convertViaJSON(&xr, observedComposite.Resource); err != nil {
		response.Fatal(rsp, fmt.Errorf("cannot convert xr: %w", err))
		return rsp, nil
	}

	protectionLevel := xr.Spec.ProtectionLevel
	if protectionLevel == nil || *protectionLevel == "" {
		response.Fatal(rsp, fmt.Errorf("missing protectionLevel %w", err))
		return rsp, nil
	}

	desiredComposed := make(map[resource.Name]any)
	defer func() {
		desiredComposedResources, err := request.GetDesiredComposedResources(req)
		if err != nil {
			response.Fatal(rsp, fmt.Errorf("cannot get desired resources: %w", err))
			return
		}

		for name, obj := range desiredComposed {
			c := composed.New()
			if err := convertViaJSON(c, obj); err != nil {
				response.Fatal(rsp, fmt.Errorf("cannot convert %s to unstructured %w", name, err))
				return
			}
			desiredComposedResources[name] = &resource.DesiredComposed{Resource: c}
		}

		if err := response.SetDesiredComposedResources(rsp, desiredComposedResources); err != nil {
			response.Fatal(rsp, fmt.Errorf("cannot set desired resources: %w", err))
			return
		}

		// Update status of composite
		err = observedComposite.Resource.SetValue("status.dummy", "cool-status")
		if err != nil {
			response.Fatal(rsp, fmt.Errorf("cannot set status %w", err))
			return
		}
		if err := response.SetDesiredCompositeResource(rsp, observedComposite); err != nil {
			response.Fatal(rsp, fmt.Errorf("cannot set composite %w", err))
			return
		}
	}()

	name := fmt.Sprintf("%s-encryption", *xr.Metadata.Name)
	cryptoKey := &v1beta2.CryptoKey{
		APIVersion: ptr.To(v1beta2.CryptoKeyAPIVersionkmsGcpUpboundIoV1Beta2),
		Kind:       ptr.To(v1beta2.CryptoKeyKindCryptoKey),
		Metadata: &v1.ObjectMeta{
			Name: &name,
		},
		Spec: &v1beta2.CryptoKeySpec{
			DeletionPolicy: ptr.To(v1beta2.CryptoKeySpecDeletionPolicyDelete),
			ForProvider: &v1beta2.CryptoKeySpecForProvider{
				VersionTemplate: &v1beta2.CryptoKeySpecForProviderVersionTemplate{
					Algorithm:       ptr.To("GOOGLE_SYMMETRIC_ENCRYPTION"),
					ProtectionLevel: protectionLevel,
				},
			},
			ManagementPolicies: &[]v1beta2.CryptoKeySpecManagementPoliciesItem{
				"*",
			},
		},
	}

	desiredComposed["cryptokey"] = cryptoKey

	// Return early if Crossplane hasn't observed the cryptokey yet. This means it
	// hasn't been created yet. This function will be called again after it is.
	_, ok := observedComposed["cryptokey"]
	if !ok {
		response.Normal(rsp, "waiting for crpytokey to be created").TargetCompositeAndClaim()
		return rsp, nil
	}
	//

	// You can set a custom status condition on the claim. This allows you to
	// communicate with the user. See the link below for status condition
	// guidance.
	// https://github.com/kubernetes/community/blob/master/contributors/devel/sig-architecture/api-conventions.md#typical-status-properties
	response.ConditionTrue(rsp, "FunctionSuccess", "Success").
		TargetCompositeAndClaim().WithMessage("Function completed successfully")

	return rsp, nil
}

func convertViaJSON(to, from any) error {
	bs, err := json.Marshal(from)
	if err != nil {
		return err
	}
	return json.Unmarshal(bs, to)
}
