data "kustomization_overlay" "provider_opentofu" {
  resources = ["kustomize/crossplane-provider-opentofu/"]

  patches {
    patch = jsonencode([
      {
        op    = "replace"
        path  = "/spec/package"
        value = "xpkg.upbound.io/upbound/provider-opentofu:${local.provider_opentofu_latest_release}"
      },
    ])
    target {
      group = "pkg.crossplane.io"
      kind  = "Provider"
    }
  }
}

resource "kustomization_resource" "provider_opentofu_p0" {
  for_each = data.kustomization_overlay.provider_opentofu.ids_prio[0]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.provider_opentofu.manifests[each.value])
    : data.kustomization_overlay.provider_opentofu.manifests[each.value]
  )
}

resource "kustomization_resource" "provider_opentofu_p1" {
  for_each = data.kustomization_overlay.provider_opentofu.ids_prio[1]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.provider_opentofu.manifests[each.value])
    : data.kustomization_overlay.provider_opentofu.manifests[each.value]
  )
  wait = true
  timeouts {
    create = "2m"
    update = "2m"
  }

  depends_on = [kustomization_resource.provider_opentofu_p0]
}

resource "kustomization_resource" "provider_opentofu_p2" {
  for_each = data.kustomization_overlay.provider_opentofu.ids_prio[2]

  manifest = (
    contains(["_/Secret"], regex("(?P<group_kind>.*/.*)/.*/.*", each.value)["group_kind"])
    ? sensitive(data.kustomization_overlay.provider_opentofu.manifests[each.value])
    : data.kustomization_overlay.provider_opentofu.manifests[each.value]
  )

  depends_on = [kustomization_resource.provider_opentofu_p1]
}

data "external" "provider_opentofu_latest_release" {
  program = ["python3", "${path.module}/get_latest_release.py"]

  query = {
    repo = "upbound/provider-opentofu"
  }
}

locals {
  provider_opentofu_latest_release = data.external.provider_opentofu_latest_release.result["tag_name"]
}
