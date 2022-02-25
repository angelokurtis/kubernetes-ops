locals {
  domain           = "lvh.me"
  default_timeouts = "5m"
  flux             = {
    version          = "v0.27.1"
    default_interval = "60m"
  }
  istio = {
    version = "1.13.1"
  }
  keycloak = {
    host = "keycloak.${local.domain}"
  }
}
