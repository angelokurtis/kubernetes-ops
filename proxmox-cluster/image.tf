locals {
  talos = {
    factory_url = "https://factory.talos.dev"
    platform    = "nocloud"
    arch        = "amd64"
    version     = "v1.11.0"
  }
}

data "http" "schematic_id" {
  url          = "${local.talos.factory_url}/schematics"
  method       = "POST"
  request_body = file("${path.module}/image/schematic.yaml")
}

resource "proxmox_virtual_environment_download_file" "talos_image" {
  node_name               = "pve"
  content_type            = "iso"
  datastore_id            = "local"
  decompression_algorithm = "gz"
  overwrite               = false

  url       = "${local.talos.factory_url}/image/${jsondecode(data.http.schematic_id.response_body)["id"]}/${local.talos.version}/${local.talos.platform}-${local.talos.arch}.raw.gz"
  file_name = "talos-${jsondecode(data.http.schematic_id.response_body)["id"]}-${local.talos.version}-${local.talos.platform}-${local.talos.arch}.img"
}

resource "talos_machine_secrets" "_" {
  talos_version = local.talos.version
}
