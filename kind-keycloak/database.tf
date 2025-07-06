locals {
  databases = [
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
  interval: 60s
  chart:
    spec:
      chart: postgresql
      reconcileStrategy: ChartVersion
      version: "^15.0.0"
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: default
  values:
    primary:
      initdb:
        scriptsSecret: "${kubernetes_secret.userdata.metadata[0].name}"
    fullnameOverride: postgresql
YAML

  depends_on = [
    kubernetes_job_v1.wait_flux_crd,
    kubectl_manifest.bitnami_helm_repository
  ]
}

resource "kubernetes_namespace" "postgresql" {
  metadata { name = local.postgresql.namespace }
}
