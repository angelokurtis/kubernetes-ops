resource "kubernetes_secret" "jwt_token" {
  metadata {
    name = "jwt-token"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "jwt-token" = "4ff42f67-5929-fc52-65f1-3afc77ad86d5"
  }
}

resource "kubernetes_secret" "smtp" {
  metadata {
    name = "smtp"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "username" = "3dcf6374062286"
    "password" = "1a29e895468521"
  }
}

resource "kubernetes_secret" "platform_database" {
  metadata {
    name = "platform-database"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "username" = local.database.platform.username
    "password" = local.database.platform.password
  }
}

resource "kubernetes_secret" "analytic_database" {
  metadata {
    name = "analytic-database"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "username" = local.database.analytic.username
    "password" = local.database.analytic.password
  }
}
