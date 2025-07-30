
import models.io.sijoma.v1alpha1 as sijomav1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.gcp.kms.v1beta2 as kmsv1beta2

# Unfortunately, we cannot use these as the input XR, these are only used for assertions
_baseXR = sijomav1alpha1.XEncryptionKey{
  metadata.name:"my-encryption-key"
  spec.protectionLevel:""
  status: {
    dummy:"cool-status"
  }
}

_baseXRHardwareProtected = _baseXR {
  spec.protectionLevel= "Hardware"
}

_baseCreatedKMS = kmsv1beta2.CryptoKey{
  metadata.name:"my-encryption-key-encryption"
  spec.forProvider.versionTemplate.algorithm:"GOOGLE_SYMMETRIC_ENCRYPTION"
}

_createdKmsHardwareProtected = _baseCreatedKMS{
  spec.forProvider.versionTemplate.protectionLevel= "Hardware"
}


_items = [
    metav1alpha1.CompositionTest{
        metadata.name: "test-encryption-key-kcl"
        spec= {
            assertResources: [
              _baseXRHardwareProtected
              _createdKmsHardwareProtected
            ]
            compositionPath: "apis/xencryptionkeys/kcl-composition.yaml"
            xrPath: "examples/kcl-xencryptionkey.yaml"
            xrdPath: "apis/xencryptionkeys/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    },
    metav1alpha1.CompositionTest{
        metadata.name: "test-encryption-key-go"
        spec= {
            assertResources: [
              _baseXRHardwareProtected
              _createdKmsHardwareProtected
            ]
            compositionPath: "apis/xencryptionkeys/go-composition.yaml"
            xrPath: "examples/go-xencryptionkey.yaml"
            xrdPath: "apis/xencryptionkeys/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
    metav1alpha1.CompositionTest{
        metadata.name: "test-encryption-key-go-templating"
        spec= {
            assertResources: [
              _baseXRHardwareProtected
              _createdKmsHardwareProtected
            ]
            compositionPath: "apis/xencryptionkeys/go-tmpl-composition.yaml"
            xrPath: "examples/go-tmpl-xencryptionkey.yaml"
            xrdPath: "apis/xencryptionkeys/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
    metav1alpha1.CompositionTest{
        metadata.name: "test-encryption-key-cue"
        spec= {
            assertResources: [
              _baseXRHardwareProtected
              _createdKmsHardwareProtected
            ]
            compositionPath: "apis/xencryptionkeys/cue-composition.yaml"
            xrPath: "examples/cue-xencryptionkey.yaml"
            xrdPath: "apis/xencryptionkeys/definition.yaml"
            timeoutSeconds: 60
            validate: False
        }
    }
]
items= _items
