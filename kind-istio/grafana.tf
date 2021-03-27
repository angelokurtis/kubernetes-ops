resource "helm_release" "grafana" {
  count = var.addons.grafana.enabled ? 1 : 0

  name = "grafana"
  namespace = kubernetes_namespace.istio_system.metadata[0].name

  repository = "https://grafana.github.io/helm-charts"
  chart = "grafana"
  version = "5.8.10"

  values = [
    yamlencode({
      "admin" = { "existingSecret" = true }
      "dashboardProviders" = {
        "dashboardproviders.yaml" = {
          "apiVersion" = 1
          "providers" = [
            {
              disableDeletion = false
              folder = "istio"
              name = "istio"
              options = { "path" = "/var/lib/grafana/dashboards/istio" }
              orgId = 1
              type = "file"
            },
            {
              disableDeletion = false
              folder = "istio"
              name = "istio-services"
              options = { "path" = "/var/lib/grafana/dashboards/istio-services" }
              orgId = 1
              type = "file"
            },
          ]
        }
      }
      "dashboardsConfigMaps" = {
        "istio" = "istio-grafana-dashboards"
        "istio-services" = "istio-services-grafana-dashboards"
      }
      "datasources" = {
        "datasources.yaml" = {
          "apiVersion" = 1
          "datasources" = [ {
              access = "proxy"
              editable = true
              isDefault = true
              jsonData = { "timeInterval" = "5s" }
              name = "Prometheus"
              orgId = 1
              type = "prometheus"
              url = "http://prometheus.${kubernetes_namespace.istio_system.metadata[0].name}.svc.cluster.local:9090"
          } ]
        }
      }
      "env" = {
        "GF_AUTH_ANONYMOUS_ENABLED" = "true"
        "GF_AUTH_ANONYMOUS_ORG_ROLE" = "Admin"
        "GF_AUTH_BASIC_ENABLED" = "false"
        "GF_SECURITY_ADMIN_PASSWORD" = "-"
        "GF_SECURITY_ADMIN_USER" = "-"
      }
      "ldap" = { "existingSecret" = true }
      "podAnnotations" = { "sidecar.istio.io/inject" = "false" }
      "podLabels" = { "app" = "grafana" }
      "rbac" = { "create" = false, "pspEnabled" = false }
      "service" = { "port" = 3000 }
      "testFramework" = { "enabled" = false }
    })
  ]

  depends_on = [
    kustomization_resource.istio
  ]
}

resource "kustomization_resource" "grafana_virtual_service" {
  count = var.addons.grafana.enabled ? 1 : 0

  manifest = jsonencode({
    "apiVersion" = "networking.istio.io/v1alpha3"
    "kind" = "VirtualService"
    "metadata" = {
      "name" = "grafana-ui"
      "namespace" = kubernetes_namespace.istio_system.metadata[0].name
    }
    "spec" = {
      "gateways" = [ local.addons_gateway.name ]
      "hosts" = [ local.grafana.host ]
      "http" = [ {
        route = [ {
          destination = {
            "host" = "grafana.${kubernetes_namespace.istio_system.metadata[0].name}.svc.cluster.local"
            "port" = { "number" = 20001 }
          }
        } ]
      } ]
    }
  })

  depends_on = [
    helm_release.grafana,
    kustomization_resource.addons_gateway,
  ]
}
