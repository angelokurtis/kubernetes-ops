resource "docker_container" "registry" {
  count = var.enable_local_registry ? 1 : 0

  name = var.registry_name
  image = "registry:2"
  restart = "always"

  ports {
    external = var.registry_port
    internal = var.registry_port
  }

  networks_advanced {
    name = data.docker_network.kind.name
  }
}

data "docker_network" "kind" {
  name = "kind"

  depends_on = [
    kind_cluster.istio
  ]
}
