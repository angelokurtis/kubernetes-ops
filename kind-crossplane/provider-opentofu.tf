data "kustomization_overlay" "provider_opentofu" {
  resources = ["kustomize/crossplane-provider-opentofu/"]
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
