locals {
  fluxcd = {
    version          = "v0.32.0"
    namespace        = "fluxcd"
    default_interval = "5s"
    default_timeout  = "5m"
  }
}

data "flux_install" "main" {
  version        = local.fluxcd.version
  target_path    = "fluxcd"
  namespace      = local.fluxcd.namespace
  network_policy = false
  components     = ["source-controller", "helm-controller"]
}

data "kubectl_file_documents" "fluxcd" {
  content = data.flux_install.main.content
}

resource "kubectl_manifest" "fluxcd" {
  for_each          = data.kubectl_file_documents.fluxcd.manifests
  server_side_apply = true
  yaml_body         = each.value

  depends_on = [kubernetes_namespace.fluxcd]
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name   = local.fluxcd.namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = local.fluxcd.version
    }
  }
}
