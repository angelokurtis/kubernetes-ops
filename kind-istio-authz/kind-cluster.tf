resource "kind_cluster" "istio_cluster" {
  name           = "istio-cluster"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:c195c17f2a9f6ad5bbddc9eb8bad68fa21709162aabf2b84e4a3896db05c0808" # v1.22.7

      kubeadm_config_patches = [
        yamlencode({
          "kind"             = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
      ]

      extra_mounts {
        container_path = "/var/lib/containerd"
        host_path      = "/var/lib/docker/volumes/${var.docker_volume}/_data"
      }

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
