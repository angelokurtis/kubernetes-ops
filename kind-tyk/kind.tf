resource "kind_cluster" "tyk" {
  name = "tyk"
  wait_for_ready = true

  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      image = "kindest/node:v1.18.15"

      kubeadm_config_patches = [
        yamlencode({
          "kind" = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
      ]

      extra_port_mappings {
        container_port = 8080
        host_port = 8080
        protocol = "TCP"
      }
    }
  }
}