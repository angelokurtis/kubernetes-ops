resource "kubectl_manifest" "helm_repository_nginx" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: nginx
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://kubernetes.github.io/ingress-nginx
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_nginx" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: nginx
      namespace: ${kubernetes_namespace.nginx.metadata[0].name}
    spec:
      chart:
        spec:
          chart: ingress-nginx
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: nginx
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.nginx_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "nginx_helm_values" {
  metadata {
    name      = "nginx-helm-values"
    namespace = kubernetes_namespace.nginx.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      controller = {
        extraArgs      = { publish-status-address = "127.0.0.1" }
        hostPort       = { enabled = true, ports = { http = 80, https = 443 } }
        nodeSelector   = { "ingress-ready" = "true", "kubernetes.io/os" = "linux" }
        publishService = { enabled = false }
        service        = { type = "NodePort" }
      }
    })
  }
}

resource "kubernetes_namespace" "nginx" {
  metadata { name = "nginx" }
}
