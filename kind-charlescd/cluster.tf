resource "kind_cluster" "charlescd" {
  name           = "charlescd"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:9d07ff05e4afefbba983fac311807b3c17a5f36e7061f6cb7e2ba756255b2be4" # v1.21.2

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
