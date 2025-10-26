locals {
  talos_install_image = "${local.talos_factory_host}/installer/${local.talos_schematic_id}:${local.talos_version}"
}

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
    "scsi0",
    "ide2",
  ]

  network_device {
    bridge   = "vmbr0"
    firewall = true
  }
}

data "talos_machine_configuration" "control_plane" {
  for_each         = { for vm in proxmox_virtual_environment_vm.control_plane : vm.name => vm }
  cluster_name     = local.cluster_name
  cluster_endpoint = local.cluster_endpoint
  talos_version    = local.talos_version
  machine_type     = "controlplane"
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
      }
    })
  ]
}

output "control_plane" {
  value = {
    for idx, vm in proxmox_virtual_environment_vm.control_plane :
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
