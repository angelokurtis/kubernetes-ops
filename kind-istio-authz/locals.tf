locals {
  ingress_ip       = "127.0.0.1"
  cluster_host     = local.ingress_ip == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", local.ingress_ip)))}.nip.io"
  default_timeouts = "5m"
  fluxcd           = {
    version          = "v0.27.4"
    default_interval = "60m"
    default_timeout  = "5m"
    namespace        = "fluxcd"
  }
  istio = {
    version   = "1.13.2"
    namespace = "istio"
  }
  keycloak = {
    host      = "keycloak.${local.cluster_host}"
    namespace = "keycloak"
  }
  postgresql = {
    namespace = "postgresql"
  }
}
