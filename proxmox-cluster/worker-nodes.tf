locals {
  workers = {
    for _, vm in proxmox_virtual_environment_vm.worker :
    vm.name => {
      mac = one([
        for nd in vm.network_device :
        nd.mac_address
        if nd.bridge == "vmbr0"
      ])

      ip = vm.ipv4_addresses[
        index(
          vm.mac_addresses,
          one([
            for nd in vm.network_device :
            nd.mac_address
            if nd.bridge == "vmbr0"
          ])
        )
      ][0]
    }
  }
}

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
    "scsi0",
    "ide2",
  ]

  network_device {
    bridge   = "vmbr0"
    firewall = true
  }
}

data "talos_machine_configuration" "worker" {
  for_each         = { for vm in proxmox_virtual_environment_vm.worker : vm.name => vm }
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  talos_version    = local.talos_version
  machine_type     = "worker"
  machine_secrets  = talos_machine_secrets._.machine_secrets
  config_patches = [
    yamlencode({
      machine = {
        network = {
          hostname = each.key
        }
        install = {
          extraKernelArgs = [
            "net.ifnames=0"
          ]
          image = local.talos_install_image
        }
        nodeLabels = {
          "topology.kubernetes.io/region" = "br-southeast-1a" # São Carlos - SP
          "topology.kubernetes.io/zone"   = local.proxmox_node_name
        }
      }
      cluster = {
        proxy   = { disabled = true }
        network = { cni = { name = "none" } } # We install Cilium manually
        apiServer = {
          certSANs = [
            "127.0.0.1"
          ]
        }
      }
    })
  ]
}

resource "talos_machine_configuration_apply" "worker" {
  for_each                    = { for vm in proxmox_virtual_environment_vm.worker : vm.name => vm }
  node                        = local.workers[each.key].ip
  endpoint                    = local.workers[each.key].ip
  client_configuration        = talos_machine_secrets._.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration

  depends_on = [data.talos_machine_configuration.worker]
}

output "workers" {
  value = local.workers
}
