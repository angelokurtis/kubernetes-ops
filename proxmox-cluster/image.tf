locals {
  talos = {
    factory_url = "https://factory.talos.dev"
    platform    = "nocloud"
    arch        = "amd64"
    version     = "v1.11.0"
  }
  proxmox_node_name = "pve"
  proxmox_iso_datastore = one([
    for ds in data.proxmox_virtual_environment_datastores._.datastores :
    ds if contains(ds["content_types"], "iso")
  ])
}

data "http" "schematic_id" {
  url          = "${local.talos.factory_url}/schematics"
  method       = "POST"
  request_body = file("${path.module}/image/schematic.yaml")
}

data "proxmox_virtual_environment_datastores" "_" {
  node_name = local.proxmox_node_name
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  node_name    = local.proxmox_node_name
  url          = "${local.talos.factory_url}/image/${jsondecode(data.http.schematic_id.response_body)["id"]}/${local.talos.version}/${local.talos.platform}-${local.talos.arch}.iso"
  file_name    = "talos-${jsondecode(data.http.schematic_id.response_body)["id"]}-${local.talos.version}-${local.talos.platform}-${local.talos.arch}.iso"
  content_type = "iso"
  datastore_id = local.proxmox_iso_datastore["id"]
}

resource "talos_machine_secrets" "_" {
  talos_version = local.talos.version
}
