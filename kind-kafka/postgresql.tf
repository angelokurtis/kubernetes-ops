locals {
  postgresql = {
    fullnameOverride = "postgresql"
    primary          = { initdb = { scriptsSecret = kubernetes_secret.userdata.metadata[0].name } }
  }
  databases = [
    "zug_partner_assestment",
  ]
  database = {
    for db in local.databases : db => {
      database = "${db}_db"
      user     = db
      password = random_password.databases[db].result
    }
  }
}

resource "random_password" "databases" {
  for_each = toset(local.databases)
  keepers  = { database = each.key }
  length   = 16
  special  = false
}

resource "kubernetes_secret" "userdata" {
  metadata {
    name      = "userdata"
    namespace = kubernetes_namespace_v1.postgresql.metadata[0].name
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

resource "kubernetes_namespace_v1" "postgresql" {
  metadata { name = "postgresql" }
}

output "databases" {
  value = [
    "jdbc:postgresql://${local.database["zug_partner_assestment"]["user"]}:${nonsensitive(local.database["zug_partner_assestment"]["password"])}@postgresql.${kubernetes_namespace_v1.postgresql.metadata[0].name}:5432/${local.database["zug_partner_assestment"]["database"]}"
  ]
}
