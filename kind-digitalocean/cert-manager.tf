resource "helm_release" "cert_manager" {
  name = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.4.1"

  values = [ yamlencode({ "installCRDs" = true }) ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}
