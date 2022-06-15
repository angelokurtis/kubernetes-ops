resource "kind_cluster" "one" {
  name = "cluster-one"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:${local.kind.version}"

      extra_mounts {
        container_path = "/var/lib/containerd"
        host_path      = "/var/lib/docker/volumes/${var.docker_volume_one}/_data"
      }

      kubeadm_config_patches = [
        yamlencode({
          kind             = "InitConfiguration"
          nodeRegistration = { kubeletExtraArgs = { "node-labels" = "ingress-ready=true" } }
        })
      ]

      extra_port_mappings {
        container_port = 32080
        host_port      = 8081
        protocol       = "TCP"
      }
    }
  }
}

resource "kind_cluster" "two" {
  name = "cluster-two"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:${local.kind.version}"

      extra_mounts {
        container_path = "/var/lib/containerd"
        host_path      = "/var/lib/docker/volumes/${var.docker_volume_two}/_data"
      }

      kubeadm_config_patches = [
        yamlencode({
          kind             = "InitConfiguration"
          nodeRegistration = { kubeletExtraArgs = { "node-labels" = "ingress-ready=true" } }
        })
      ]

      extra_port_mappings {
        container_port = 32080
        host_port      = 8082
        protocol       = "TCP"
      }
    }
  }
}
