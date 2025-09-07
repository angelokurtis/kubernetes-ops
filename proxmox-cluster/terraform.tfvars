cluster = {
  name            = "talos"
  endpoint        = "192.168.1.100"
  gateway         = "192.168.1.1"
  talos_version   = "v1.7"
  proxmox_cluster = "homelab"
}

nodes = {
  "ctrl-00" = {
    host_node     = "zulmira"
    machine_type  = "controlplane"
    ip            = "192.168.1.100"
    vm_id         = 800
    cpu           = 1
    ram_dedicated = 4096
  }
  "ctrl-01" = {
    host_node     = "dolores"
    machine_type  = "controlplane"
    ip            = "192.168.1.101"
    vm_id         = 801
    cpu           = 1
    ram_dedicated = 4096
  }
  "work-00" = {
    host_node     = "lourdes"
    machine_type  = "worker"
    ip            = "192.168.1.110"
    vm_id         = 810
    cpu           = 1
    ram_dedicated = 4096
  }
}
