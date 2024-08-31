resource "kind_cluster" "ktstst" {
  name           = "ktstst"
  node_image     = "kindest/node:${local.kind.version}"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    networking {
      disable_default_cni = true
      pod_subnet          = "192.168.0.0/16"
    }

    node {
      role = "control-plane"
    }

    node {
      role = "worker"
    }

    node {
      role = "worker"
    }
  }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.ktstst]
}
