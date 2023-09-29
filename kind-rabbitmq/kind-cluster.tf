locals {
  cluster_host = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  kind         = { version = "v1.27.3" }
}

resource "kind_cluster" "rabbitmq" {
  name = "rabbitmq"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:${local.kind.version}"
    }

    node {
      role  = "worker"
      image = "kindest/node:${local.kind.version}"

      dynamic "extra_mounts" {
        for_each = toset(var.docker_volume != null ? [var.docker_volume] : [])
        content {
          container_path = "/var/lib/containerd"
          host_path      = "/var/lib/docker/volumes/${var.docker_volume}/_data"
        }
      }

      kubeadm_config_patches = [
        yamlencode({
          kind             = "JoinConfiguration"
          nodeRegistration = { kubeletExtraArgs = { "node-labels" = "ingress-ready=true" } }
        })
      ]

      extra_port_mappings {
        container_port = 80
        host_port      = 80
        protocol       = "TCP"
      }
    }
  }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.rabbitmq]
}
