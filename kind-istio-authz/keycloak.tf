resource "kubectl_manifest" "keycloak_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: keycloak
  namespace: ${kubernetes_namespace.keycloak.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: keycloak
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: default
  values:
    auth:
      adminUser: admin
      existingSecretPerPassword:
        adminPassword:
          name: ${kubernetes_secret.keycloak_passwords.metadata[0].name}
        databasePassword:
          name: ${kubernetes_secret.keycloak_passwords.metadata[0].name}
        managementPassword:
          name: ${kubernetes_secret.keycloak_passwords.metadata[0].name}
    externalDatabase:
      existingSecret: ${kubernetes_secret.database_env_vars.metadata[0].name}
    extraEnvVars:
      - name: KEYCLOAK_LOGLEVEL
        value: DEBUG
      - name: ROOT_LOGLEVEL
        value: DEBUG
    ingress:
      annotations:
        "kubernetes.io/ingress.class": istio
      enabled: true
      hostname: "${local.keycloak.host}"
      pathType: Prefix
    postgresql:
      enabled: false
    service:
      type: ClusterIP
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository,
    kubectl_manifest.postgresql_helm_release,
  ]
}

resource "random_password" "keycloak_admin" {
  length = 16
}

resource "random_password" "keycloak_management" {
  length = 16
}

resource "kubernetes_secret" "keycloak_passwords" {
  metadata {
    name      = "keycloak-passwords"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    adminPassword      = random_password.keycloak_admin.result
    managementPassword = random_password.keycloak_management.result
    databasePassword   = local.database["keycloak"]["password"]
  }
}

resource "kubernetes_secret" "database_env_vars" {
  metadata {
    name      = "database-env-vars"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    KEYCLOAK_DATABASE_HOST = "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
    KEYCLOAK_DATABASE_PORT = 5432
    KEYCLOAK_DATABASE_NAME = local.database["keycloak"]["database"]
    KEYCLOAK_DATABASE_USER = local.database["keycloak"]["user"]
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata { name = local.keycloak.namespace }
}

resource "kubernetes_service_account_v1" "keycloak_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}

resource "kubernetes_role_v1" "postgresql_helmreleases_reader" {
  metadata {
    name      = "postgresql-helmreleases-reader"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_postgresql_helmreleases_reader" {
  metadata {
    name      = "kubectl-postgresql-helmreleases-reader"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.postgresql_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}

resource "kubernetes_job_v1" "wait_postgresql" {
  metadata {
    name      = "wait-postgresql"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = [
            "wait", "--for=condition=Ready", "helmrelease/postgresql",
            "--timeout", local.default_timeouts,
            "-n", kubernetes_namespace.postgresql.metadata[0].name
          ]
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = local.default_timeouts
    update = local.default_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.kubectl_postgresql_helmreleases_reader,
    kubectl_manifest.postgresql_helm_release,
  ]
}
