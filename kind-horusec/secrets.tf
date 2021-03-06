resource "kubernetes_secret" "jwt_token" {
  metadata {
    name = "jwt-token"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "jwt-token" = uuid()
  }
}

resource "kubernetes_secret" "broker_username" {
  metadata {
    name = "broker-username"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "broker-username" = "user"
  }
}

resource "kubernetes_secret" "broker_password" {
  metadata {
    name = "broker-password"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "broker-password" = data.kubernetes_secret.horusec_rabbitmq.data.rabbitmq-password
  }
}

data "kubernetes_secret" "horusec_rabbitmq" {
  metadata {
    name = helm_release.rabbit.name
    namespace = helm_release.rabbit.namespace
  }

  depends_on = [
    helm_release.rabbit
  ]
}

resource "kubernetes_secret" "database_uri" {
  metadata {
    name = "database-uri"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "database-uri" = "postgresql://${kubernetes_secret.database_username.data.database-username}:${kubernetes_secret.database_password.data.database-password}@${helm_release.postgres.name}.${helm_release.postgres.namespace}:5432/horusec_db?sslmode=disable"
  }
}

resource "kubernetes_secret" "database_username" {
  metadata {
    name = "database-username"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "database-username" = "postgres"
  }
}

resource "kubernetes_secret" "database_password" {
  metadata {
    name = "database-password"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }

  data = {
    "database-password" = data.kubernetes_secret.horusec_postgresql.data.postgresql-password
  }
}

data "kubernetes_secret" "horusec_postgresql" {
  metadata {
    name = helm_release.postgres.name
    namespace = helm_release.postgres.namespace
  }

  depends_on = [
    helm_release.postgres
  ]
}
