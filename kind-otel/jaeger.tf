resource "kubectl_manifest" "helm_repository_jaeger" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: jaeger
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://jaegertracing.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_jaeger" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: jaeger
      namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
    spec:
      chart:
        spec:
          chart: jaeger
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: jaeger
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.jaeger_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "jaeger_helm_values" {
  metadata {
    name      = "jaeger-helm-values"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      allInOne = {
        enabled  = true
        image    = "jaegertracing/all-in-one"
        tag      = "1.52.0"
        ingress  = { enabled = false }
        extraEnv = [
          {
            name  = "METRICS_STORAGE_TYPE",
            value = "prometheus"
          },
          {
            name  = "PROMETHEUS_SERVER_URL",
            value = "http://prometheus-server.${kubernetes_namespace.prometheus.metadata[0].name}"
          }
        ]
      }

      collector = { enabled = false }
      agent     = { enabled = false }
      query     = { enabled = false }

      provisionDataStore = {
        cassandra     = false
        elasticsearch = false
        kafka         = false
      }
    })
  }
}

resource "kubernetes_ingress_v1" "jaeger" {
  metadata {
    name      = "jaeger"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "jaeger.${local.cluster_host}"
      http {
        path {
          path = "/"
          backend {
            service {
              name = "jaeger-query"
              port {
                name = "http-query"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = "jaeger" }
}
