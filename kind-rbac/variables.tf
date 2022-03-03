locals {
  domain           = "lvh.me"
  default_timeouts = "5m"
  flux             = {
    namespace        = "fluxcd"
    version          = "0.27.3"
    default_interval = "60m"
  }
  rbac_manager = {
    namespace = "rbac-manager"
    version   = "1.1.1"
  }
}
