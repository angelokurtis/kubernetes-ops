locals {
  talos_version  = data.external.talos_latest_release.result.tag_name
  talos_arch     = "amd64"
  talos_platform = "nocloud"

  talos_factory_scheme = "https"
  talos_factory_host   = "factory.talos.dev"
  talos_factory_url    = "${local.talos_factory_scheme}://${local.talos_factory_host}"
  talos_schematic_id   = jsondecode(data.http.schematic_id.response_body)["id"]
  talos_install_image  = "${local.talos_factory_host}/installer/${local.talos_schematic_id}:${local.talos_version}"

  proxmox_node_name = "pve"
  proxmox_iso_datastore = one([
    for ds in data.proxmox_virtual_environment_datastores._.datastores :
    ds if contains(ds["content_types"], "iso")
  ])
}

data "external" "talos_latest_release" {
  program = ["python3", "${path.module}/get_latest_github_release_version.py"]

  query = {
    repo   = "siderolabs/talos"
    semver = ">= 1.0.0, < 2.0.0"
  }
}

data "http" "schematic_id" {
  url    = "${local.talos_factory_url}/schematics"
  method = "POST"
  request_body = yamlencode({
    customization = {
      systemExtensions = {
        officialExtensions = [
          "siderolabs/qemu-guest-agent",
        ]
      }
    }
  })
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
