resource "kubectl_manifest" "keycloak_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: keycloak
  namespace: ${kubernetes_namespace.keycloak.metadata[0].name}
spec:
  dependsOn:
    - name: postgresql
      namespace: ${kubernetes_namespace.postgresql.metadata[0].name}
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: keycloak
      reconcileStrategy: ChartVersion
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

resource "kubectl_manifest" "keycloak_gateway" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: Gateway
metadata:
  name: keycloak
  namespace: ${kubernetes_namespace.keycloak.metadata[0].name}
spec:
  selector:
    istio: "ingressgateway"
  servers:
    - hosts:
        - ${local.keycloak.host}
      port:
        name: http
        number: 80
        protocol: HTTP
YAML

  depends_on = [
    kubernetes_job_v1.wait_istio,
    kubectl_manifest.kiali_helm_release
  ]
}

resource "kubectl_manifest" "keycloak_virtual_service" {
  yaml_body = <<YAML
apiVersion: networking.istio.io/v1alpha3
kind: VirtualService
metadata:
  name: keycloak
  namespace: ${kubernetes_namespace.keycloak.metadata[0].name}
spec:
  gateways:
    - keycloak
  hosts:
    - ${local.keycloak.host}
  http:
    - route:
        - destination:
            host: "keycloak.${kubernetes_namespace.keycloak.metadata[0].name}.svc.cluster.local"
            port:
              number: 80
YAML

  depends_on = [
    kubernetes_job_v1.wait_istio,
    kubectl_manifest.keycloak_helm_release
  ]
}

resource "kubernetes_namespace" "keycloak" {
  metadata { name = local.keycloak.namespace }
}
