locals {
  cluster_host = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  kind = { version = "v1.31.0" }
  fluxcd = {
    default_interval = "60m"
  }
}
