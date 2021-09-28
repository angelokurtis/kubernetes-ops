locals {
  cluster_domain = "lvh.me"
}

resource "kind_cluster" "charlescd" {
  name           = "charlescd"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node:v1.20.7"

      kubeadm_config_patches = [
        yamlencode({
          "kind"             = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
        }),
        yamlencode({
          "apiVersion" = "kubeadm.k8s.io/v1beta2"
          "kind"       = "ClusterConfiguration"
          "metadata"   = { "name" = "config" }
          "apiServer"  = {
            "extraArgs" = {
              "service-account-issuer"           = "kubernetes.default.svc"
              "service-account-signing-key-file" = "/etc/kubernetes/pki/sa.key"
            }
          }
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
