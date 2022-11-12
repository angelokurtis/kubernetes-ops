locals {
  kustomizations = {}
}

resource "kubectl_manifest" "kustomization" {
  for_each = local.kustomizations

  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "kustomize.toolkit.fluxcd.io/v1beta2"
    kind       = "Kustomization"
    metadata   = { name = each.key, namespace = each.value.namespace }
    spec       = {
      interval  = local.fluxcd.default_interval
      path      = try(each.value.path, "")
      prune     = try(each.value.prune, true)
      sourceRef = {
        kind      = "GitRepository"
        name      = kubectl_manifest.git_repository[each.value.git_repository].name
        namespace = kubectl_manifest.git_repository[each.value.git_repository].namespace
      }
      targetNamespace = each.value.namespace
      images          = try(each.value.images, [])
      patches         = try(each.value.patches, [])
      dependsOn       = try(each.value.dependsOn, [])
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
