resource "kubectl_manifest" "helm_release_keycloak" {
  yaml_body = <<YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: keycloak
      namespace: ${kubernetes_namespace.keycloak.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.keycloak_helm_values.data["values.yaml"])}
    spec:
      dependsOn:
        - name: postgresql
          namespace: ${kubernetes_namespace.postgresql.metadata[0].name}
      interval: 60s
      chart:
        spec:
          chart: keycloak
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: bitnami
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.keycloak_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [
    kubernetes_job_v1.wait_flux_crd,
    kubectl_manifest.helm_repository_bitnami,
    kubectl_manifest.postgresql_helm_release,
  ]
}

resource "kubernetes_config_map_v1" "keycloak_helm_values" {
  metadata {
    name      = "keycloak-helm-values"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      auth = {
        adminUser      = "admin"
        existingSecret = kubernetes_secret_v1.keycloak_passwords.metadata[0].name
      }
      externalDatabase = {
        existingSecret            = kubernetes_secret_v1.database_credentials.metadata[0].name
        existingSecretDatabaseKey = "db-name"
        existingSecretHostKey     = "db-host"
        existingSecretPasswordKey = "db-password"
        existingSecretPortKey     = "db-port"
        existingSecretUserKey     = "db-user"
      }
      extraEnvVars = [
        {
          name  = "KEYCLOAK_LOGLEVEL"
          value = "DEBUG"
        },
        {
          name  = "ROOT_LOGLEVEL"
          value = "DEBUG"
        },
      ]
      ingress = {
        enabled          = true
        hostname         = "keycloak.${local.cluster_host}"
        ingressClassName = "nginx"
      }
      postgresql = { enabled = false }
      service = { type = "ClusterIP" }
    })
  }
}

resource "random_password" "keycloak_admin" {
  length = 16
}

resource "random_password" "keycloak_management" {
  length = 16
}

resource "kubernetes_secret_v1" "keycloak_passwords" {
  metadata {
    name      = "keycloak-passwords"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    admin-password      = random_password.keycloak_admin.result
    management-password = random_password.keycloak_management.result
    database-password   = local.database["keycloak"]["password"]
  }
}

resource "kubernetes_secret_v1" "database_credentials" {
  metadata {
    name      = "database-credentials"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    db-host     = "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
    db-port     = 5432
    db-name     = local.database["keycloak"]["database"]
    db-user     = local.database["keycloak"]["user"]
    db-password = local.database["keycloak"]["password"]
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata { name = "keycloak" }
}
