resource "kustomization_resource" "istio" {
  manifest = jsonencode({
    "apiVersion" = "install.istio.io/v1alpha1"
    "kind" = "IstioOperator"
    "metadata" = {
      "name" = "control-plane"
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "profile" = "demo"
      "meshConfig" = {
        "defaultConfig" = { "tracing" = { "zipkin" = { "address" = "jaeger-collector:9411" }, "sampling" = 100 } }
      }
      "components" = {
        "egressGateways" = [ { enabled = false, name = "istio-egressgateway" } ]
        "ingressGateways" = [
          {
            name = "istio-ingressgateway"
            enabled = true
            k8s = {
              "nodeSelector" = { "ingress-ready" = "true" }
              "service" = {
                "ports" = [
                  { name = "status-port", nodePort = 30002, port = 15021, targetPort = 15021 },
                  { name = "http2", nodePort = 30000, port = 80, targetPort = 8080 },
                  { name = "https", nodePort = 30001, port = 443, targetPort = 8443 },
                ]
              }
            }
          },
        ]
      }
      "values" = {
        "gateways" = { "istio-ingressgateway" = { "type" = "NodePort" } }
        "global" = {
          "defaultPodDisruptionBudget" = { "enabled" = false }
          "logging" = { "level" = "default:debug" }
          "proxy" = { "componentLogLevel" = "misc:debug", "logLevel" = "debug" }
        }
      }
    }
  })

  depends_on = [
    helm_release.istio_operator
  ]
}
