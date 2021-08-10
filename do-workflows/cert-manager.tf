locals {
  cert_manager = {
    name = "cert-manager"
    destination = { namespace = "certificates", server = "https://kubernetes.default.svc" }
    source = {
      chart = "cert-manager"
      helm = { parameters = [ { name = "installCRDs", value = "true" } ] }
      repoURL = "https://charts.jetstack.io"
      targetRevision = "v1.4.3"
    }
  }
}