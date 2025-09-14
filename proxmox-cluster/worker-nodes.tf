resource "proxmox_virtual_environment_vm" "worker" {
  count       = var.worker_count
  node_name   = local.proxmox_node_name
  name        = "k8s-wrk-${count.index + 1}"
  description = "Kubernetes worker node for running containerized workloads."
  tags = [
    "k8s",
    "talos",
    "worker",
  ]
  on_boot       = true
  vm_id         = 801 + count.index
  scsi_hardware = "virtio-scsi-single"

  agent {
    enabled = true
  }

  cpu {
    cores = 1
    units = 100
    numa  = false
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 1024 # 1 GiB
    floating  = 1024
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

data "talos_machine_configuration" "worker" {
  for_each     = { for vm in proxmox_virtual_environment_vm.worker : vm.name => vm }
  cluster_name = local.cluster_name
  cluster_endpoint = format(
    "https://%s:6443",
    [
      for ip in flatten(proxmox_virtual_environment_vm.control_plane[0].ipv4_addresses) : ip
      if ip != "127.0.0.1"
    ][0]
  )
  talos_version   = local.talos_version
  machine_type    = "worker"
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

  depends_on = [proxmox_virtual_environment_vm.worker]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = { for vm in proxmox_virtual_environment_vm.worker : vm.name => vm }
  node                        = [for ip in flatten(each.value.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
  client_configuration        = talos_machine_secrets._.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration

  depends_on = [data.talos_machine_configuration.worker]
}

resource "talos_machine_bootstrap" "worker" {
  for_each             = talos_machine_configuration_apply.worker
  node                 = each.value.node
  client_configuration = each.value.client_configuration

  depends_on = [talos_machine_configuration_apply.worker]
}

output "workers" {
  value = [
    for vm in proxmox_virtual_environment_vm.worker : {
      name = vm.name
      ip   = [for ip in flatten(vm.ipv4_addresses) : ip if ip != "127.0.0.1"][0]
      mac  = [for nic in vm.network_device : nic.mac_address if nic.bridge == "vmbr0"][0]
    }
  ]
}
