data "flux_install" "main" {
  version        = local.flux.version
  target_path    = "fluxcd"
  namespace      = var.fluxcd_namespace
  network_policy = false
}

data "kubectl_file_documents" "fluxcd" {
  content = data.flux_install.main.content
}

resource "kubectl_manifest" "fluxcd_one" {
  provider = "kubectl.cluster_one"

  for_each  = data.kubectl_file_documents.fluxcd.manifests
  yaml_body = each.value

  depends_on = [kubernetes_namespace.fluxcd_one]
}

resource "kubernetes_namespace" "fluxcd_one" {
  provider = "kubernetes.cluster_one"

  metadata {
    name   = var.fluxcd_namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = local.flux.version
    }
  }
}

resource "kubectl_manifest" "fluxcd_two" {
  provider = "kubectl.cluster_two"

  for_each  = data.kubectl_file_documents.fluxcd.manifests
  yaml_body = each.value

  depends_on = [kubernetes_namespace.fluxcd_two]
}

resource "kubernetes_namespace" "fluxcd_two" {
  provider = "kubernetes.cluster_two"

  metadata {
    name   = var.fluxcd_namespace
    labels = {
      "app.kubernetes.io/instance" = "fluxcd"
      "app.kubernetes.io/part-of"  = "flux"
      "app.kubernetes.io/version"  = local.flux.version
    }
  }
}
