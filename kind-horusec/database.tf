locals {
  database = {
    platform = { database = "horusec_db", username = "platform", password = "ada875581dfb" }
    analytic = { database = "analytic_db", username = "analytic", password = "4dffe5f19a27" }
  }
}

resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.database.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "10.5.1"

  set {
    name = "initdbScriptsSecret"
    value = kubernetes_secret.userdata.metadata[0].name
  }

  set {
    name = "nameOverride"
    value = "postgresql"
  }
}

resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}

resource "kubernetes_secret" "userdata" {
  metadata {
    name = "userdata"
    namespace = kubernetes_namespace.database.metadata[0].name
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