locals {
  tracing_gateway = "tracing"
  tracing_ingress_domain = "tracing.${var.ingress_domain}"
}

resource "kustomization_resource" "tracing_gateway" {
  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "Gateway"
    "metadata" = {
      "name" = local.tracing_gateway
      "namespace" = kubernetes_namespace.tracing.metadata[0].name
    }
    "spec" = {
      "selector" = { "istio" = "ingressgateway" }
      "servers" = [
        {
          hosts = [ local.tracing_ingress_domain ]
          port = { "name" = "http", "number" = 80, "protocol" = "HTTP" }
        },
      ]
    }
  })

  depends_on = [
    kustomization_resource.istio,
    kustomization_resource.jaeger_custom_resource
  ]
}

resource "kustomization_resource" "tracing_virtual_service" {
  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "VirtualService"
    "metadata" = {
      "name" = "jaeger-ui"
      "namespace" = kubernetes_namespace.tracing.metadata[0].name
    }
    "spec" = {
      "gateways" = [ local.tracing_gateway ]
      "hosts" = [ local.tracing_ingress_domain ]
      "http" = [
        {
          route = [
            {
              destination = {
                "host" = "jaeger-query.${kubernetes_namespace.tracing.metadata[0].name}.svc.cluster.local"
                "port" = { "number" = 16686 }
              }
            },
          ]
        },
      ]
    }
  })

  depends_on = [
    kustomization_resource.tracing_gateway
  ]
}