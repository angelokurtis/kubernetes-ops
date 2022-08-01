locals {
  cluster_host     = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  default_timeouts = "5m"
  kind             = { version = "v1.21.12" }
  fluxcd           = {
    version           = "v0.31.5"
    default_interval  = "5s"
    default_timeout   = "5m"
  }
}
