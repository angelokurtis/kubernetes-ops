resource "helm_release" "cert_manager" {
  name = "cert-manager"
  namespace = kubernetes_namespace.cert_manager.metadata[0].name

  repository = "https://charts.jetstack.io"
  chart = "cert-manager"
  version = "v1.4.1"

  values = [ yamlencode({ "installCRDs" = true }) ]
}

resource "kustomization_resource" "letsencrypt_prod" {
  manifest = jsonencode({
    apiVersion = "cert-manager.io/v1"
    kind = "ClusterIssuer"
    metadata = { name = "letsencrypt" }
    spec = {
      acme = {
        email = var.email
        privateKeySecretRef = { name = "letsencrypt" }
        server = "https://acme-v02.api.letsencrypt.org/directory"
        solvers = [ { http01 = { ingress = { class = "nginx" } } } ]
      }
    }
  })

  depends_on = [ helm_release.cert_manager ]
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}