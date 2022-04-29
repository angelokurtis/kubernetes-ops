locals {
  cluster_host     = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  default_timeouts = "5m"
  fluxcd           = {
    version          = "v0.29.5"
    default_interval = "60m"
    default_timeout  = "5m"
    namespace        = "fluxcd"
  }
  tektoncd = {
    operator = { version = "v0.57.0" }
  }
}
