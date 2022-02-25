resource "kubectl_manifest" "charlescd_git_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: GitRepository
metadata:
  name: charlescd
  namespace: ${kubernetes_namespace.charlescd.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://github.com/ZupIT/charlescd
  ref:
    branch: "main"
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "charlescd_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: charlescd
  namespace: ${kubernetes_namespace.charlescd.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  values:
    CharlesApplications:
      butler:
        database:
          host: postgresql.postgresql.svc.cluster.local
          name: charlescd_butler_db
          password: W9SOIlBfhHLk5dhy
          user: charlescd_butler
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
      circleMatcher:
        allowedOriginHost: "http://${local.charlescd.host}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        redis:
          host: "redis-master.${kubernetes_namespace.redis.metadata[0].name}.svc.cluster.local"
          password: "${random_password.redis.result}"
        resources:
          limits: null
      compass:
        database:
          host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
          name: ${local.database["charlescd_compass"]["database"]}
          user: "${local.database["charlescd_compass"]["user"]}"
          password: "${local.database["charlescd_compass"]["password"]}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        moove:
          database:
            host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
            name: ${local.database["charlescd_moove"]["database"]}
            user: "${local.database["charlescd_moove"]["user"]}"
            password: "${local.database["charlescd_moove"]["password"]}"
        pullPolicy: IfNotPresent
        resources:
          limits: null
      gate:
        database:
          host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
          name: ${local.database["charlescd_moove"]["database"]}
          user: "${local.database["charlescd_moove"]["user"]}"
          password: "${local.database["charlescd_moove"]["password"]}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
      hermes:
        amqp:
          url: "amqp://user:${random_password.rabbitmq["password"].result}@rabbitmq.${kubernetes_namespace.keycloak.metadata[0].name}.svc.cluster.local:5672/"
        database:
          host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
          name: ${local.database["charlescd_hermes"]["database"]}
          user: "${local.database["charlescd_hermes"]["user"]}"
          password: "${local.database["charlescd_hermes"]["password"]}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
      moove:
        allowedOriginHost: "http://${local.charlescd.host}"
        database:
          host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
          name: ${local.database["charlescd_moove"]["database"]}
          user: "${local.database["charlescd_moove"]["user"]}"
          password: "${local.database["charlescd_moove"]["password"]}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
      ui:
        allowedOriginHost: "http://${local.charlescd.host}"
        apiHost: "http://${local.charlescd.host}"
        authUri: "http://${local.keycloak.host}"
        healthCheck:
          initialDelay: 5
        idmRedirectHost: "http://${local.charlescd.host}"
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
      villager:
        database:
          host: "postgresql.${kubernetes_namespace.postgresql.metadata[0].name}.svc.cluster.local"
          name: ${local.database["charlescd_villager"]["database"]}
          user: "${local.database["charlescd_villager"]["user"]}"
          password: "${local.database["charlescd_villager"]["password"]}"
        healthCheck:
          initialDelay: 5
        image:
          tag: ${local.charlescd.version}
        pullPolicy: IfNotPresent
        resources:
          limits: null
    envoy:
      idm:
        endpoint: "${local.keycloak.host}"
        path: /auth/realms/charlescd/protocol/openid-connect/userinfo
    hostGlobal: "http://${local.charlescd.host}"
    ingress:
      enabled: false
    keycloak:
      enabled: false
    nginx_ingress_controller:
      enabled: false
    postgresql:
      enabled: false
    rabbitmq:
      enabled: false
    redis:
      enabled: false
  chart:
    spec:
      chart: install/helm-chart
      sourceRef:
        kind: GitRepository
        name: charlescd
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.charlescd_git_repository
  ]
}

resource "kubernetes_namespace" "charlescd" {
  metadata { name = var.charlescd_namespace }
}

resource "kubernetes_ingress_v1" "charlescd" {
  metadata {
    name        = "charlescd-ingress"
    namespace   = kubernetes_namespace.charlescd.metadata[0].name
    annotations = {
      "kubernetes.io/ingress.class" = "istio"
    }
  }
  spec {
    rule {
      host = local.charlescd.host
      http {
        path {
          backend {
            service {
              name = "envoy-proxy"
              port {
                number = 80
              }
            }
          }
        }
      }
    }
  }

  depends_on = [kubectl_manifest.charlescd_helm_release]
}
