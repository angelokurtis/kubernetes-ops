locals {
  database = {
    platform = { database = "horusec_db", username = "platform", password = "ada875581dfb" }
    analytic = { database = "analytic_db", username = "analytic", password = "4dffe5f19a27" }
  }
}

resource "helm_release" "postgres" {
  name = "horusec-database"
  chart = "https://charts.bitnami.com/bitnami/postgresql-10.4.8.tgz"
  namespace = kubernetes_namespace.horusec.metadata[0].name

  set {
    name = "postgresqlPassword"
    value = "c9e7678d535a"
  }

  set {
    name = "initdbScriptsSecret"
    value = kubernetes_secret.userdata.metadata[0].name
  }
}

resource "kubernetes_secret" "platform-db" {
  metadata {
    name = "platform-db"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }
  data = {
    postgresql-username = local.database.platform.username
    postgresql-password = local.database.platform.password
  }
}

resource "kubernetes_secret" "analytic_db" {
  metadata {
    name = "analytic-db"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }
  data = {
    postgresql-username = local.database.analytic.username
    postgresql-password = local.database.analytic.password
  }
}

resource "kubernetes_secret" "userdata" {
  metadata {
    name = "userdata"
    namespace = kubernetes_namespace.horusec.metadata[0].name
  }
  data = {
    "userdata.sql" = <<-EOT
      create database ${local.database.platform.database};
      create user ${local.database.platform.username} with encrypted password '${local.database.platform.password}';
      grant all privileges on database ${local.database.platform.database} to ${local.database.platform.username};

      create database ${local.database.analytic.database};
      create user ${local.database.analytic.username} with encrypted password '${local.database.analytic.password}';
      grant all privileges on database ${local.database.analytic.database} to ${local.database.analytic.username};
    EOT
  }
}