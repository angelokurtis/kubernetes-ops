resource "kubernetes_namespace" "horusec_system" {
  metadata {
    name = var.horusec_namespace
  }
}

resource "kubernetes_secret" "horusec_broker" {
  metadata {
    name = "horusec-broker"
    namespace = kubernetes_namespace.horusec_system.metadata[0].name
  }

  data = {
    "username" = "user"
    "password" = data.kubernetes_secret.rabbit.data.rabbitmq-password
  }
}

resource "kubernetes_secret" "platform_db" {
  metadata {
    name = "platform-db"
    namespace = kubernetes_namespace.horusec_system.metadata[0].name
  }
  data = {
    postgresql-username = local.database.platform.username
    postgresql-password = local.database.platform.password
  }
}

resource "kubernetes_secret" "analytic_db" {
  metadata {
    name = "analytic-db"
    namespace = kubernetes_namespace.horusec_system.metadata[0].name
  }
  data = {
    postgresql-username = local.database.analytic.username
    postgresql-password = local.database.analytic.password
  }
}

resource "kubernetes_secret" "horusec_jwt" {
  metadata {
    name = "horusec-jwt"
    namespace = kubernetes_namespace.horusec_system.metadata[0].name
  }

  data = {
    "secret-key" = "74266279-766d-3075-7a2f-36587132a5eb"
  }
}

resource "kubernetes_secret" "horusec_smtp" {
  metadata {
    name = "horusec-smtp"
    namespace = kubernetes_namespace.horusec_system.metadata[0].name
  }

  data = {
    "username" = "56188f6b9189fc"
    "password" = "5ef8b1c956f4c6"
  }
}
