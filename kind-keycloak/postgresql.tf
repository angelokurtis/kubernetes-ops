locals {
  databases = ["keycloak"]

  database_credentials = {
    for db in local.databases : db => {
      database = "${db}_db"
      user     = db
      password = random_password.databases[db].result
    }
  }

  userdata_sql = join("\n", [
    for db in local.databases : <<-SQL
      CREATE DATABASE ${local.database_credentials[db].database};
      CREATE USER ${local.database_credentials[db].user} WITH ENCRYPTED PASSWORD '${local.database_credentials[db].password}';
      ALTER USER ${local.database_credentials[db].user} WITH SUPERUSER;
      GRANT ALL PRIVILEGES ON DATABASE ${local.database_credentials[db].database} TO ${local.database_credentials[db].user};
    SQL
  ])
}

resource "kubectl_manifest" "helm_repository_bitnami" {
  yaml_body = <<YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta1
    kind: HelmRepository
    metadata:
      name: bitnami
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.bitnami.com/bitnami
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_postgresql" {
  yaml_body = <<YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: postgresql
      namespace: ${kubernetes_namespace.postgresql.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.postgresql_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: postgresql
          version: "^15.0.0"
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: bitnami
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.postgresql_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [
    kubectl_manifest.helm_repository_bitnami,
    kubernetes_job_v1.wait_flux_crd
  ]
}

resource "kubernetes_config_map_v1" "postgresql_helm_values" {
  metadata {
    name      = "postgresql-helm-values"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  data = {
    "values.yaml" = yamlencode({
      fullnameOverride = "postgresql"
      primary = {
        initdb = {
          scriptsSecret = "userdata"
        }
      }
    })
  }
}

resource "random_password" "databases" {
  for_each = toset(local.databases)

  length  = 16
  special = false
  keepers = { database = each.key }
}

resource "kubernetes_secret" "userdata" {
  metadata {
    name      = "userdata"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  data = {
    "userdata.sql" = base64encode(local.userdata_sql)
  }
}

resource "kubernetes_namespace" "postgresql" {
  metadata { name = "postgresql" }
}
