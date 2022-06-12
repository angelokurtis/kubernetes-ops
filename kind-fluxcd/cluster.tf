resource "kind_cluster" "flux" {
  name = "flux"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:${local.kind.version}"

      kubeadm_config_patches = [
        yamlencode({
          kind             = "InitConfiguration"
          nodeRegistration = { kubeletExtraArgs = { "node-labels" = "ingress-ready=true" } }
        })
      ]

      extra_mounts {
        container_path = "/var/lib/containerd"
        host_path      = "/var/lib/docker/volumes/${var.docker_volume}/_data"
      }

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