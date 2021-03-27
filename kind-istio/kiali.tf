resource "helm_release" "kiali" {
  count = var.addons.kiali.enabled ? 1 : 0

  name = "kiali"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://kiali.org/helm-charts"
  chart = "kiali-server"
  version = "1.29.0"

  set {
    name = "nameOverride"
    value = "kiali"
  }

  set {
    name = "fullnameOverride"
    value = "kiali"
  }

  values = [
    yamlencode({
      "auth" = { "strategy" = "anonymous" }
      "deployment" = {
        "accessible_namespaces" = [ "**" ]
        "image_version" = "v1.29"
        "ingress_enabled" = "false"
        "pod_annotations" = { "sidecar.istio.io/inject" = "false" }
      }
      "login_token" = { "signing_key" = "CHANGEME" }
      "external_services" = {
        "tracing" = { "in_cluster_url" = "http://jaeger-query:16686/jaeger" }
        "grafana" = { "in_cluster_url" = "http://grafana:3000" }
      }
    })
  ]

  depends_on = [
    kustomization_resource.istio
  ]
}

resource "kustomization_resource" "kiali_virtual_service" {
  count = var.addons.kiali.enabled ? 1 : 0

  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "VirtualService"
    "metadata" = {
      "name" = "kiali-ui"
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "gateways" = [ local.addons_gateway.name ]
      "hosts" = [ local.kiali.host ]
      "http" = [ {
          route = [ {
              destination = {
                "host" = "kiali.${kubernetes_namespace.istio_system.metadata[0].name}.svc.cluster.local"
                "port" = { "number" = 20001 }
              }
          } ]
      } ]
    }
  })

  depends_on = [
    helm_release.kiali,
    kustomization_resource.addons_gateway,
  ]
}