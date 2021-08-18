resource "kubernetes_pod" "openssh_server" {
  metadata {
    name = "openssh-server"
    namespace = "default"
    labels = { "app" = "openssh-server" }
  }
  spec {
    container {
      env {
        name = "USER_NAME"
        value = "linuxserver"
      }
      env {
        name = "PUBLIC_KEY"
        value_from {
          secret_key_ref {
            key = "id_rsa.pub"
            name = kubernetes_secret.ssh_public_key.metadata[0].name
          }
        }
      }
      image = "ghcr.io/linuxserver/openssh-server"
      image_pull_policy = "IfNotPresent"
      name = "openssh-server"
      port { container_port = 2222 }
    }
    restart_policy = "Always"
  }
}
