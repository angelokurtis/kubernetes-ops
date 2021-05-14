resource "helm_release" "linkerd" {
  name = "linkerd"
  namespace = kubernetes_namespace.mesh.metadata[0].name

  repository = "https://helm.linkerd.io/stable"
  chart = "linkerd2"
  version = "2.10.1"

  values = [
    yamlencode({
      namespace = kubernetes_namespace.mesh.metadata[0].name
      installNamespace = false
      identityTrustAnchorsPEM = local.ca.public_key
      identity = {
        issuer = {
          crtExpiry = formatdate("YYYY-MM-DD'T'HH:mm:ssZ", tls_self_signed_cert.ca.validity_end_time)
          tls = { crtPEM = local.issuer.public_key, keyPEM = local.issuer.private_key }
        }
      }
    })
  ]
}

resource "kubernetes_namespace" "mesh" {
  metadata {
    name = "mesh"
  }
}
