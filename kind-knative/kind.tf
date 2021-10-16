locals {
  cluster_domain = "${join("", formatlist("%02x", split(".", "192.168.0.17")))}.nip.io"
}

resource "kind_cluster" "knative" {
  name           = "knative"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:f638a08c1f68fe2a99e724ace6df233a546eaf6713019a0b310130a4f91ebe7f" # v1.22.2

      kubeadm_config_patches = [
        yamlencode({
          "kind"             = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
      ]

      extra_port_mappings {
        container_port = 30000
        host_port      = 80
      }
      extra_port_mappings {
        container_port = 30001
        host_port      = 443
      }
      extra_port_mappings {
        container_port = 30002
        host_port      = 15021
      }
    }
  }
}
