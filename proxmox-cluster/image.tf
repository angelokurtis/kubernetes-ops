locals {
  talos_version  = "v1.11.3"
  talos_arch     = "amd64"
  talos_platform = "nocloud"

  talos_factory_scheme = "https"
  talos_factory_host   = "factory.talos.dev"
  talos_factory_url    = "${local.talos_factory_scheme}://${local.talos_factory_host}"
  talos_schematic_id   = jsondecode(data.http.schematic_id.response_body)["id"]

  proxmox_node_name = "pve"
  proxmox_iso_datastore = one([
    for ds in data.proxmox_virtual_environment_datastores._.datastores :
    ds if contains(ds["content_types"], "iso")
  ])
}

data "http" "schematic_id" {
  url          = "${local.talos_factory_url}/schematics"
  method       = "POST"
  request_body = file("${path.module}/image/schematic.yaml")
}

data "proxmox_virtual_environment_datastores" "_" {
  node_name = local.proxmox_node_name
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  node_name    = local.proxmox_node_name
  url          = "${local.talos_factory_url}/image/${local.talos_schematic_id}/${local.talos_version}/${local.talos_platform}-${local.talos_arch}.iso"
  file_name    = "talos-${local.talos_schematic_id}-${local.talos_version}-${local.talos_platform}-${local.talos_arch}.iso"
  content_type = "iso"
  datastore_id = local.proxmox_iso_datastore["id"]
}
