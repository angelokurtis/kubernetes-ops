resource "kubernetes_secret" "jwt_token" {
  metadata {
    name = "jwt-token"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "jwt-token" = "4ff42f67-5929-fc52-65f1-3afc77ad86d5"
  }
}

resource "kubernetes_secret" "smtp_username" {
  metadata {
    name = "smtp-username"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "smtp-username" = "3dcf6374062286"
  }
}

resource "kubernetes_secret" "smtp_password" {
  metadata {
    name = "smtp-password"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "smtp-password" = "1a29e895468521"
  }
}
