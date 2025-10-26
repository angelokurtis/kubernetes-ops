locals {
  cluster_name       = "homelab-talos-dev"
  cluster_endpoint = format(
    "https://%s:6443",
    proxmox_virtual_environment_vm.control_plane[0].ipv4_addresses[
      index(
        proxmox_virtual_environment_vm.control_plane[0].mac_addresses,
        one([
          for nd in proxmox_virtual_environment_vm.control_plane[0].network_device :
          nd.mac_address
          if nd.bridge == "vmbr0"
        ])
      )
    ][0]
  )
}

resource "talos_machine_secrets" "_" {}

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
