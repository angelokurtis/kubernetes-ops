resource "kind_cluster" "flux" {
  name           = "flux"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:ca3587e6e545a96c07bf82e2c46503d9ef86fc704f44c17577fca7bcabf5f978" # v1.22.4

      kubeadm_config_patches = [
        yamlencode({
          "kind"             = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
      ]

      extra_port_mappings {
        container_port = 32080
        host_port      = 80
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 32443
        host_port      = 443
        protocol       = "TCP"
      }

      extra_port_mappings {
        container_port = 32090
        host_port      = 9000
        protocol       = "TCP"
      }
    }
  }
}