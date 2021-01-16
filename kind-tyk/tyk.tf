resource "helm_release" "tyk_gateway" {
  chart = "${path.module}/tyk-headless"
  name = "tyk-gateway"
  version = "0.4.0"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 60

  values = [
    yamlencode({
      "enableSharding" = true
      "fullnameOverride" = "tyk-headless"
      "gateway" = {
        "affinity" = {}
        "containerPort" = 8080
        "extraEnvs" = []
        "hostName" = "gateway.tykbeta.com"
        "image" = { "pullPolicy" = "IfNotPresent", "repository" = "tykio/tyk-gateway", "tag" = "latest" }
        "ingress" = { "annotations" = {}, "enabled" = false, "hosts" = [ "tyk-gw.local", ], "path" = "/", "tls" = [] }
        "kind" = "DaemonSet"
        "nodeSelector" = {}
        "replicaCount" = 1
        "resources" = {}
        "service" = { "annotations" = {}, "externalTrafficPolicy" = "Local", "port" = 443, "type" = "LoadBalancer" }
        "tags" = "ingress"
        "tls" = true
        "tolerations" = [ { effect = "NoSchedule", key = "node-role.kubernetes.io/master" }, ]
      }
      "mongo" = {
        "mongoURL" = "mongodb://root:pass@tyk-mongo-mongodb.tyk-ingress.svc.cluster.local:27017/tyk-dashboard?authSource=admin"
        "useSSL" = false
      }
      "nameOverride" = ""
      "pump" = {
        "affinity" = {}
        "annotations" = {}
        "extraEnvs" = []
        "image" = { "pullPolicy" = "IfNotPresent", "repository" = "tykio/tyk-pump-docker-pub", "tag" = "latest" }
        "nodeSelector" = {}
        "replicaCount" = 1
        "resources" = {}
        "tolerations" = []
      }
      "rbac" = true
      "redis" = { "host" = "tyk-redis-master.tyk-ingress.svc.cluster.local", "port" = 6379, "shardCount" = 128, "useSSL" = false }
      "secrets" = { "APISecret" = "CHANGEME", "OrgID" = "1" }
      "tyk_k8s" = {
        "affinity" = {}
        "image" = { "pullPolicy" = "Always", "repository" = "tykio/tyk-k8s", "tag" = "headless" }
        "nodeSelector" = {}
        "resources" = {}
        "serviceMesh" = { "enabled" = false }
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

resource "helm_release" "tyk_mongo" {
  repository = "https://charts.helm.sh/stable"
  chart = "stable/mongodb"
  name = "tyk-mongo"
  version = "7.8.10"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 60

  set {
    name = "replicaSet.enabled"
    value = "true"
  }
}

resource "helm_release" "tyk_redis" {
  repository = "https://charts.helm.sh/stable"
  chart = "stable/redis"
  name = "tyk-redis"
  version = "7.8.10"
  namespace = kubernetes_namespace.tyk_ingress.metadata[0].name
  timeout = 60
}

resource "kubernetes_namespace" "tyk_ingress" {
  metadata {
    name = "tyk-ingress"
  }
}