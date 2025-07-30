
import models.io.sijoma.v1alpha1 as sijomav1alpha1
import models.io.upbound.dev.meta.v1alpha1 as metav1alpha1
import models.io.upbound.gcp.v1beta1 as gcpv1beta1


_items = [
    metav1alpha1.E2ETest{
        metadata.name: "non-working-e2e-test"
        spec= {
            crossplane.autoUpgrade.channel: "Rapid"
            defaultConditions: ["Ready"]
            manifests: [
              sijomav1alpha1.XEncryptionKey{
                metadata.name: "my-encryption-key"
                spec.protectionLevel: "Hardware"
              }
            ]
            extraResources: [
              gcpv1beta1.ProviderConfig{
                metadata.name = "default"
                spec.projectID= "project-id"
                spec.credentials: {
                  source:"Secret"
                  secretRef: {
                    name: "gcp-creds"
                    namespace: "crossplane-system"
                    key: "credentials.json"
                  }
                }
              }
            ]
            skipDelete: False
            timeoutSeconds: 4500
        }
    }
]
items= _items
