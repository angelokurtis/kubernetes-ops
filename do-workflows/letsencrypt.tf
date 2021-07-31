locals {
  lets_encrypt = {
    name = "letsencrypt"
    destination = { namespace = "certificates", server = "https://kubernetes.default.svc" }
    source = {
      path = "letsencrypt/overlays/angelokurtis"
      repoURL = "https://github.com/angelokurtis/k8s-automation"
      targetRevision = "HEAD"
    }
  }
}