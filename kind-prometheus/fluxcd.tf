data "flux_install" "main" {
  version        = local.fluxcd.version
  target_path    = "fluxcd"
  namespace      = var.fluxcd_namespace
  network_policy = false
}

data "kubectl_file_documents" "fluxcd" {
  content = data.flux_install.main.content
}

resource "kubectl_manifest" "fluxcd" {
  for_each  = data.kubectl_file_documents.fluxcd.manifests
  yaml_body = each.value

  depends_on = [kubernetes_namespace.fluxcd]
}

resource "kubernetes_namespace" "fluxcd" {
  metadata {
    name   = var.fluxcd_namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = local.fluxcd.version
    }
  }
}
