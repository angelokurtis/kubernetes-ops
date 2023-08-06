locals {
  cluster_host = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  kind         = { version = "v1.27.3" }
  worker_nodes = 3
}

resource "kind_cluster" "cilium" {
  name       = "cilium"
  node_image = "kindest/node:${local.kind.version}"

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      disable_default_cni = true
    }

    node {
      role = "control-plane"

      dynamic "extra_mounts" {
        for_each = toset(var.image_caching ? ["cilium-control-plane"] : [])
        content {
          container_path = "/var/lib/containerd"
          host_path      = "/var/lib/docker/volumes/${extra_mounts.value}/_data"
        }
      }
    }

    dynamic "node" {
      for_each = range(local.worker_nodes)
      content {
        role = "worker"

        dynamic "extra_mounts" {
          for_each = toset(var.image_caching ? ["cilium-worker${node.value == 0 ? "" : node.value+1}"] : [])
          content {
            container_path = "/var/lib/containerd"
            host_path      = "/var/lib/docker/volumes/${extra_mounts.value}/_data"
          }
        }
      }
    }
  }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.cilium]
}
