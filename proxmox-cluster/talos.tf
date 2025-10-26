locals {
  cluster_name = "homelab-talos-dev"
  cluster_endpoint = format(
    "https://%s:6443",
    values(local.control_planes)[0].ip
  )
}

resource "talos_machine_secrets" "_" {}

data "talos_client_configuration" "_" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets._.client_configuration
  nodes                = concat(values(local.control_planes)[*].ip, values(local.workers)[*].ip)
  endpoints            = values(local.control_planes)[*].ip
}
