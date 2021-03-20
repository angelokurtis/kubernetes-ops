resource "helm_release" "istio_operator" {
  name = "istio-operator"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-operator-1.9.1.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  set {
    name = "operatorNamespace"
    value = "istio-operator"
  }

  set {
    name = "watchedNamespaces"
    value = kubernetes_namespace.istio_system.metadata[0].name
  }
}

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
        "defaultConfig" = { "tracing" = { "zipkin" = { "address" = "zipkin:9411" }, "sampling" = 100 } }
      }
      "components" = {
        "egressGateways" = [ { enabled = false, name = "istio-egressgateway" }, ]
      }
      "values" = {
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

output "istio" {
  value = yamldecode(file("istio.yaml"))
}