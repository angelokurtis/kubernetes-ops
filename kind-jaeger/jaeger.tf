locals {
  jaeger = {
    namespace       = kubernetes_namespace_v1.jaeger.metadata[0].name
    chart           = "jaeger-operator"
    helm_repository = kubectl_manifest.helm_repository["jaegertracing"]
    dependsOn       = [{ name = "cert-manager", namespace = kubernetes_namespace_v1.cert_manager.metadata[0].name }]
    values          = {
      fullnameOverride = "jaeger-operator"
      rbac             = { clusterRole = true }
      jaeger           = {
        create = true
        spec   = {
          ingress  = { enabled = true, hosts = ["jaeger.lvh.me"], ingressClassName = "nginx" }
          storage  = { type = "memory" }
          strategy = "allinone"
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "jaeger" {
  metadata { name = "jaeger" }
}
