locals {
  postgresql = {
    keycloak = { database = "keycloak_db", user = "keycloak", password = random_password.keycloak_db.result }
    apicurio = { database = "apicurio_db", user = "apicurio", password = random_password.apicurio_db.result }
  }
}

resource "random_password" "keycloak_db" {
  length = 16
  special = true
}

resource "random_password" "apicurio_db" {
  length = 16
  special = true
}

resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.database.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "10.9.4"

  set {
    name = "initdbScriptsSecret"
    value = kubernetes_secret.userdata.metadata[0].name
  }

  set {
    name = "fullnameOverride"
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

      create database ${local.postgresql.apicurio.database};
      create user ${local.postgresql.apicurio.user} with encrypted password '${local.postgresql.apicurio.password}';
      grant all privileges on database ${local.postgresql.apicurio.database} to ${local.postgresql.apicurio.user};
    EOT
  }
}