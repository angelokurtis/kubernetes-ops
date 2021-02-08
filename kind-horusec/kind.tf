resource "kind_cluster" "horusec" {
  name = "horusec"
  wait_for_ready = true

  kind_config {
    kind = "Cluster"
    api_version = "kind.x-k8s.io/v1alpha4"

    node {
      role = "control-plane"
      image = "kindest/node:v1.17.17"
    }
  }
}