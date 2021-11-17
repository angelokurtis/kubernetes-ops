locals {
  jaeger = {
    namespace = "tracing"
    query     = { host = "jaeger.lvh.me" }
    collector = { host = "jaeger-collector.lvh.me" }
  }
}

resource "kubernetes_namespace" "tracing" {
  metadata { name = local.jaeger.namespace }
}

resource "helm_release" "jaeger_operator" {
  name      = "jaeger-operator"
  namespace = kubernetes_namespace.tracing.metadata[0].name

  repository = "https://jaegertracing.github.io/helm-charts"
  chart      = "jaeger-operator"
  version    = "2.27.0"
}

resource "kustomization_resource" "jaeger" {
  for_each = data.kustomization_overlay.jaeger.ids
  manifest = data.kustomization_overlay.jaeger.manifests[each.value]

  depends_on = [helm_release.jaeger_operator]
}

resource "kubernetes_ingress" "jaeger_collector" {
  metadata {
    name      = "jaeger-collector"
    namespace = kubernetes_namespace.tracing.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = local.jaeger.collector.host
      http {
        path {
          backend {
            service_name = "jaeger-collector"
            service_port = "14268"
          }
        }
      }
    }
  }

  depends_on = [kustomization_resource.jaeger]
}

data "kustomization_overlay" "jaeger" {
  resources = ["kustomize/jaeger"]
  namespace = local.jaeger.namespace
  patches {
    patch  = yamlencode([
      {
        op    = "replace"
        path  = "/spec/ingress/hosts/0"
        value = local.jaeger.query.host
      }
    ])
    target = { kind = "Jaeger" }
  }
}