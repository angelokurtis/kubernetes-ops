resource "kind_cluster" "horusec" {
  name = "horusec"
  wait_for_ready = true

  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      image = "kindest/node:v1.20.7"

      kubeadm_config_patches = [
        yamlencode({
          "kind" = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
      ]

      extra_port_mappings {
        container_port = 80
        host_port = 80
        protocol = "TCP"
      }

      extra_port_mappings {
        container_port = 443
        host_port = 443
        protocol = "TCP"
      }
    }
  }
}