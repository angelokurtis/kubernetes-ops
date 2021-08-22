locals {
  postgresql = {
    keycloak = { database = "keycloak_db", user = "keycloak", password = "buk1azp.kqc5tbg*VZR" }
  }
}

resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.database.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "10.9.0"

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
  metadata { name = "database" }
}

resource "kubernetes_secret" "userdata" {
  metadata {
    name = "userdata"
    namespace = kubernetes_namespace.database.metadata[0].name
  }
  data = {
    "userdata.sql" = <<-EOT
      create database ${local.postgresql.keycloak.database};
      create user ${local.postgresql.keycloak.user} with encrypted password '${local.postgresql.keycloak.password}';
      grant all privileges on database ${local.postgresql.keycloak.database} to ${local.postgresql.keycloak.user};
    EOT
  }
}