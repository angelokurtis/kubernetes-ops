locals {
  cluster_name = "talos-cluster"
}

resource "talos_machine_secrets" "_" {
  talos_version = local.talos_version
}

data "talos_client_configuration" "_" {
  cluster_name         = local.cluster_name
  client_configuration = talos_machine_secrets._.client_configuration
  nodes = concat(
    [
      for vm in proxmox_virtual_environment_vm.control_plane :
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
    ],
    [
      for vm in proxmox_virtual_environment_vm.worker :
      [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
    ]
  )
  endpoints = [
    for vm in proxmox_virtual_environment_vm.control_plane :
    [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
  ]
}
