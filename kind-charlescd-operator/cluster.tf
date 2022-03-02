resource "kind_cluster" "charlescd" {
  name           = "charlescd"
  wait_for_ready = true

  kind_config {
    kind        = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role  = "control-plane"
      image = "kindest/node@sha256:0df8215895129c0d3221cda19847d1296c4f29ec93487339149333bd9d899e5a" # v1.23.3

      kubeadm_config_patches = [
        yamlencode({
          "kind"             = "InitConfiguration"
          "nodeRegistration" = { "kubeletExtraArgs" = { "node-labels" = "ingress-ready=true" } }
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

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.charlescd]
}
