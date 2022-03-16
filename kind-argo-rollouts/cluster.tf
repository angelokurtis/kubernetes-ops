resource "kind_cluster" "argo_rollouts" {
  name           = "argo-rollouts"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:1742ff7f0b79a8aaae347b9c2ffaf9738910e721d649301791c812c162092753" # v1.23.4

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
    }
  }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.argo_rollouts]
}
