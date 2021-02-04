resource "helm_release" "tyk_gateway" {
  name = "tyk-gateway"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/tyk-headless-0.4.1.tgz"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 120

  values = [
    yamlencode({
      "enableSharding" = true
      "fullnameOverride" = "tyk-headless"
      "gateway" = {
        "affinity" = {}
        "containerPort" = 8080
        "extraEnvs" = []
        "hostName" = "gateway.tykbeta.com"
        "image" = {
          "pullPolicy" = "IfNotPresent",
          "repository" = "tykio/tyk-gateway",
          "tag" = "latest"
        }
        "ingress" = {
          "annotations" = {},
          "enabled" = false,
          "hosts" = [
            "tyk-gw.local",],
          "path" = "/",
          "tls" = []
        }
        "kind" = "Deployment"
        "nodeSelector" = {
          "ingress-ready" = "true"
        }
        "replicaCount" = 1
        "resources" = {}
        "service" = {
          "annotations" = {},
          "externalTrafficPolicy" = "Local",
          "port" = 80,
          "type" = "NodePort"
        }
        "tags" = "ingress"
        "tls" = false
        "tolerations" = [
          {
            effect = "NoSchedule",
            key = "node-role.kubernetes.io/master"
          },]
      }
      "mongo" = {
        "mongoURL" = "mongodb://root:${var.mongodb_pass}@tyk-mongo-mongodb.${helm_release.tyk_mongo.namespace}.svc.cluster.local:27017/tyk-dashboard?authSource=admin"
        "useSSL" = false
      }
      "nameOverride" = ""
      "pump" = {
        "affinity" = {}
        "annotations" = {}
        "extraEnvs" = []
        "image" = {
          "pullPolicy" = "IfNotPresent",
          "repository" = "tykio/tyk-pump-docker-pub",
          "tag" = "latest"
        }
        "nodeSelector" = {}
        "replicaCount" = 1
        "resources" = {}
        "tolerations" = []
      }
      "rbac" = true
      "redis" = {
        "host" = "tyk-redis-master.${helm_release.tyk_redis.namespace}.svc.cluster.local"
        "port" = 6379
        "pass" = var.redis_pass
        "shardCount" = 128
        "useSSL" = false
      }
      "secrets" = {
        "APISecret" = "CHANGEME",
        "OrgID" = "1"
      }
      "tyk_k8s" = {
        "affinity" = {}
        "image" = {
          "pullPolicy" = "Always",
          "repository" = "tykio/tyk-k8s",
          "tag" = "headless"
        }
        "nodeSelector" = {}
        "resources" = {}
        "serviceMesh" = {
          "enabled" = false
        }
        "tolerations" = []
        "watchNamespaces" = []
      }
    })
  ]

  depends_on = [
    helm_release.tyk_mongo,
    helm_release.tyk_redis
  ]
}
//
//output "values_community_edition" {
//  value = yamldecode(file("values_community_edition.yaml"))
//}