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
