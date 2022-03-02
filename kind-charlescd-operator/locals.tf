locals {
  domain           = "lvh.me"
  default_timeouts = "5m"
  flux             = {
    namespace        = "fluxcd"
    version          = "0.27.3"
    default_interval = "60m"
  }
  istio = {
    namespace = "istio"
    version   = "1.13.1"
  }
}
