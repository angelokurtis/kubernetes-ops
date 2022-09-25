locals {
  bets = {
    kustomization_patches = [
      {
        target = { kind = "Deployment" }
        patch  = jsonencode([
          {
            op    = "add"
            path  = "/spec/template/metadata/annotations"
            value = {
              "instrumentation.opentelemetry.io/inject-java" = "true"
              "checksum/auto-instrumentation"                = sha256(kubectl_manifest.auto_instrumentation.yaml_body)
            }
          },
          { op = "replace", path = "/spec/replicas", value = 2 },
          {
            op    = "add", path = "/spec/template/spec/containers/0/env",
            value = [{ name = "LOGGING_PATTERN_LEVEL", value = "trace_id=%mdc{trace_id} span_id=%mdc{span_id} %5p" }]
          }
        ])
      }
    ]
  }
}

resource "kubectl_manifest" "auto_instrumentation" {
  server_side_apply = true
  yaml_body         = yamlencode({
    apiVersion = "opentelemetry.io/v1alpha1"
    kind       = "Instrumentation"
    metadata   = { name = "auto-instrumentation", namespace = kubernetes_namespace_v1.demo.metadata[0].name }
    spec       = {
      sampler  = { type = "always_on" }
      exporter = {
        endpoint = "http://loadbalancing-collector.${kubernetes_namespace_v1.opentelemetry.metadata[0].name}.svc.cluster.local:4317"
      }
      java = { image = "ghcr.io/open-telemetry/opentelemetry-operator/autoinstrumentation-java:1.18.0" }
      env  = [
        { name = "OTEL_TRACES_EXPORTER", value = "otlp" },
        { name = "OTEL_METRICS_EXPORTER", value = "none" },
        { name = "OTEL_LOGS_EXPORTER", value = "none" },
        { name = "OTEL_EXPERIMENTAL_EXPORTER_OTLP_RETRY_ENABLED", value = "true" }
      ]
    }
  })

  depends_on = [kubectl_manifest.fluxcd, kubernetes_job_v1.wait_helm_release["opentelemetry-operator"]]
}

resource "kubernetes_ingress_v1" "demo" {
  metadata {
    name      = "demo"
    namespace = kubernetes_namespace_v1.demo.metadata[0].name
  }
  spec {
    ingress_class_name = "nginx"
    rule {
      host = "demo.${local.cluster_host}"
      http {
        path {
          path = "/bets"
          backend {
            service {
              name = "bets"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/championships"
          backend {
            service {
              name = "championships"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/matches"
          backend {
            service {
              name = "matches"
              port {
                name = "http"
              }
            }
          }
        }
        path {
          path = "/teams"
          backend {
            service {
              name = "teams"
              port {
                name = "http"
              }
            }
          }
        }
      }
    }
  }
}

resource "kubernetes_namespace_v1" "demo" {
  metadata { name = "demo" }
}
