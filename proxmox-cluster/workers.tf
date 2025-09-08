resource "proxmox_virtual_environment_vm" "worker" {
  count       = var.worker_count
  node_name   = local.proxmox_node_name
  name        = "worker-${count.index + 1}"
  description = "Kubernetes worker node for running containerized workloads."
  tags = [
    "k8s",
    "talos",
    "worker",
  ]
  on_boot       = true
  vm_id         = 801 + count.index
  scsi_hardware = "virtio-scsi-single" # Recommended SCSI controller for performance

  agent {
    enabled = true
  }

  cpu {
    cores = 2
    units = 100
    numa  = false
    type  = "x86-64-v2-AES" # CPU type for compatibility + AES support
  }

  memory {
    dedicated = 2048
    floating  = 2048 # Max ballooned memory (MB)
  }

  operating_system {
    type = "l26" # Linux kernel 2.6/3.x/4.x (generic Linux guest type)
  }

  cdrom {
    interface = "ide2" # CD-ROM interface
    file_id   = proxmox_virtual_environment_download_file.talos_image.id
  }

  disk {
    interface    = "scsi0" # Primary disk interface
    datastore_id = "local-lvm"
    ssd          = true
    iothread     = true
    size         = 10 # Disk size in GB
  }

  boot_order = [
    "ide2",
    "scsi0",
  ]

  network_device {
    bridge   = "vmbr0" # Proxmox bridge interface (LAN)
    firewall = true
  }
}
