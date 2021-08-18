resource "kubernetes_secret" "ssh_public_key" {
  metadata {
    name = "ssh-public-key"
    namespace = data.kubernetes_namespace.default.metadata[0].name
  }
  data = {
    "authorized_keys" = tls_private_key.openssh.public_key_openssh
  }
}
