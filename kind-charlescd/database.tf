locals {
  databases = [
    "charlescd_moove",
    "charlescd_villager",
    "charlescd_butler",
    "charlescd_hermes",
    "charlescd_compass",
  ]
  database = {for db in local.databases : db => {
    database = "${db}_db"
    user = db
    password = random_password.databases[db].result
  }}
}

resource "random_password" "databases" {
  for_each = toset(local.databases)
  keepers = { database = each.key }
  length = 16
  special = false
}

resource "helm_release" "postgresql" {
  name = "postgresql"
  namespace = kubernetes_namespace.database.metadata[0].name

  repository = "https://charts.bitnami.com/bitnami"
  chart = "postgresql"
  version = "10.9.5"

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
      %{ for db in local.databases ~}
      create database ${local.database[db]["database"]};
      create user ${local.database[db]["user"]} with encrypted password '${local.database[db]["password"]}';
      grant all privileges on database ${local.database[db]["database"]} to ${local.database[db]["user"]};
      %{ endfor ~}
    EOT
  }
}