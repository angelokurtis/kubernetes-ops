locals {
  cluster_host     = var.load_balancer_address == "127.0.0.1" ? "lvh.me" : "${join("", formatlist("%02x", split(".", var.load_balancer_address)))}.nip.io"
  default_timeouts = "5m"
  kind             = { version = "v1.23.6" }
  flux             = {
    version          = "v0.31.3"
    default_interval = "10s"
    default_timeout  = "5m"
  }
  jaeger = {
    query     = { host = "jaeger.${local.cluster_host}" }
    collector = { host = "jaeger-collector.${local.cluster_host}" }
  }
}
