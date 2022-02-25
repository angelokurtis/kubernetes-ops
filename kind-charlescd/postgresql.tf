locals {
  databases = [
    "charlescd_moove",
    "charlescd_villager",
    "charlescd_butler",
    "charlescd_hermes",
    "charlescd_compass",
    "keycloak",
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
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  data = {
    "userdata.sql" = <<-EOT
      %{ for db in local.databases ~}
      create database ${local.database[db]["database"]};
      create user ${local.database[db]["user"]} with encrypted password '${local.database[db]["password"]}';
      alter user ${local.database[db]["user"]} with superuser;
      grant all privileges on database ${local.database[db]["database"]} to ${local.database[db]["user"]};
      %{ endfor ~}
    EOT
  }
}

resource "kubectl_manifest" "postgresql_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: postgresql
  namespace: ${kubernetes_namespace.postgresql.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  chart:
    spec:
      chart: postgresql
      version: ">=10.0.0 <11.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: default
  values:
    initdbScriptsSecret: "${kubernetes_secret.userdata.metadata[0].name}"
    fullnameOverride: postgresql
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "kubernetes_namespace" "postgresql" {
  metadata { name = var.postgresql_namespace }
}
