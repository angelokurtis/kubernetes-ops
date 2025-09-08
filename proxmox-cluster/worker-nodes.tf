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
