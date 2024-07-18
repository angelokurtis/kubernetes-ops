locals {
  cluster_host = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  kind = { version = "v1.30.2" }
  fluxcd = {
    default_interval = "60m"
  }
  keycloak = {
    host      = "keycloak.${local.cluster_host}"
    namespace = "keycloak"
  }
  postgresql = {
    namespace = "postgresql"
  }
}
