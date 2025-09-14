resource "proxmox_virtual_environment_vm" "control_plane" {
  count       = var.control_plane_count
  node_name   = local.proxmox_node_name
  name        = "k8s-ctrl-${count.index + 1}"
  description = "Kubernetes control plane node (API server, scheduler, controller manager, etcd)."
  tags = [
    "k8s",
    "talos",
    "control-plane",
  ]
  on_boot       = true
  vm_id         = 701 + count.index
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    units = 100
    numa  = false
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048 # 2 GiB
    floating  = 2048
  }

  operating_system {
    type = "l26"
  }

  cdrom {
    interface = "ide2"
    file_id   = proxmox_virtual_environment_download_file.talos_image.id
  }

  disk {
    interface    = "scsi0"
    datastore_id = "local-lvm"
    ssd          = true
    iothread     = true
    size         = 10 # 10 GiB
  }

  boot_order = [
    "ide2",
    "scsi0",
  ]

  network_device {
    bridge   = "vmbr0"
    firewall = true
  }
}

data "talos_machine_configuration" "control_plane" {
  for_each     = { for vm in proxmox_virtual_environment_vm.control_plane : vm.name => vm }
  cluster_name = local.cluster_name
  cluster_endpoint = format(
    "https://%s:6443",
    [
      for ip in flatten(proxmox_virtual_environment_vm.control_plane[0].ipv4_addresses) : ip
      if ip != "127.0.0.1"
    ][0]
  )
  talos_version   = local.talos_version
  machine_type    = "controlplane"
  machine_secrets = talos_machine_secrets._.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.key
        }
        nodeLabels = {
          "topology.kubernetes.io/region" = local.cluster_name
          "topology.kubernetes.io/zone"   = local.proxmox_node_name
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each                    = { for vm in proxmox_virtual_environment_vm.control_plane : vm.name => vm }
  node                        = [for ip in flatten(each.value.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
  client_configuration        = talos_machine_secrets._.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane[each.key].machine_configuration
}

output "control_plane" {
  value = [
    for vm in proxmox_virtual_environment_vm.control_plane : {
      name = vm.name
      ip   = [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
      mac  = [for nic in vm.network_device : nic.mac_address if nic.bridge == "vmbr0"][0]
    }
  ]
}
