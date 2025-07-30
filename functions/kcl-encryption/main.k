
import models.io.sijoma.v1alpha1 as sijomav1alpha1
import models.io.upbound.gcp.kms.v1beta2 as kmsv1beta2

oxr = option("params").oxr # observed composite resource
_ocds = option("params").ocds # observed composed resources
_dxr = option("params").dxr # desired composite resource
dcds = option("params").dcds # desired composed resources

encryptionName = "{}-encryption".format(oxr.metadata.name)

_metadata = lambda name: str -> any {
  {
    name = name
    annotations = {
      "krm.kcl.dev/composition-resource-name" = name
    }
  }
}

_protection_level = "Provider"
if oxr.spec?.protectionLevel:
   _protection_level = oxr.spec.protectionLevel


_gcpKmsKey = kmsv1beta2.CryptoKey{
  metadata: _metadata(encryptionName)
  spec: {
     forProvider: {
       versionTemplate: {
         algorithm: "GOOGLE_SYMMETRIC_ENCRYPTION"
         protectionLevel: _protection_level
       }
     }
  }
}

items = [_gcpKmsKey, _dxr{status.dummy = "cool-status"}]
