locals {
  git_repositories = {
    kafka-ui = {
      repository = "https://github.com/provectus/kafka-ui"
      ref        = { tag = "v0.5.0" }
    }
    kminion = {
      repository = "https://github.com/redpanda-data/kminion"
      ref        = { tag = "v2.2.1" }
    }
  }
}

resource "kubectl_manifest" "git_repository" {
  for_each = local.git_repositories

  server_side_apply = true
  yaml_body = yamlencode({
    apiVersion = "source.toolkit.fluxcd.io/v1beta2"
    kind       = "GitRepository"
    metadata   = { name = each.key, namespace = kubernetes_namespace.fluxcd.metadata[0].name }
    spec = {
      interval = local.fluxcd.default_interval
      timeout  = local.fluxcd.default_timeout
      url      = each.value.repository
      ref      = try(each.value.ref, { branch = "main" })
    }
  })

  depends_on = [kubectl_manifest.fluxcd]
}
