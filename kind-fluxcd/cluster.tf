resource "kind_cluster" "flux" {
  name           = "flux"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:0df8215895129c0d3221cda19847d1296c4f29ec93487339149333bd9d899e5a" # v1.23.3

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