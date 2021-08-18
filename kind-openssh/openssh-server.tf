resource "kubernetes_pod" "openssh_server" {
  metadata {
    name = "openssh-server"
    namespace = data.kubernetes_namespace.default.metadata[0].name
    labels = { "app" = "openssh-server" }
  }
  spec {
    container {
      name = "openssh-server"
      image = "kurtis/openssh-server"
      image_pull_policy = "IfNotPresent"
      port { container_port = 22 }
      volume_mount {
        mount_path = "/root/.ssh"
        name = "ssh-public-key"
      }
    }
    volume {
      name = "ssh-public-key"
      secret {
        secret_name = kubernetes_secret.ssh_public_key.metadata[0].name
      }
    }
    restart_policy = "Always"
  }
}
