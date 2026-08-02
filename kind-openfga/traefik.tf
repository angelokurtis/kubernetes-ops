resource "kubectl_manifest" "helm_repository_traefik" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: HelmRepository
    metadata:
      name: traefik
      namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://traefik.github.io/charts
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_traefik" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2
    kind: HelmRelease
    metadata:
      name: traefik
      namespace: ${kubernetes_namespace_v1.traefik.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.traefik_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: traefik
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: traefik
            namespace: ${kubernetes_namespace_v1.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.traefik_helm_values.metadata[0].name}
      interval: 60s
  YAML

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "traefik_helm_values" {
  metadata {
    name      = "traefik-helm-values"
    namespace = kubernetes_namespace_v1.traefik.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      ingressRoute = {
        dashboard = {
          enabled     = true
          entryPoints = ["web"]
          matchRule   = "Host(`traefik.${local.cluster_host}}`)"
        }
      }
      ports = {
        web = {
          expose      = { default = true }
          exposedPort = 80
          hostPort    = 80
        }
      }
      providers = {
        kubernetesIngress = {
          enabled          = true
          ingressEndpoint  = { ip = "127.0.0.1" }
          publishedService = { enabled = false }
        }
      }
      service = { spec = { type = "NodePort" } }
    })
  }
}

resource "kubernetes_namespace_v1" "traefik" {
  metadata { name = "traefik" }
}
