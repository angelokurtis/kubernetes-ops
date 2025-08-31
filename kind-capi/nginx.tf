resource "kubectl_manifest" "helm_repository_nginx" {
  yaml_body = templatefile("${path.module}/manifests/helmrepositories.source.toolkit.fluxcd.io/nginx.yaml", {
    namespace = kubernetes_namespace.flux.metadata[0].name
  })

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_nginx" {
  yaml_body = templatefile("${path.module}/manifests/helmreleases.helm.toolkit.fluxcd.io/nginx.yaml", {
    namespace         = kubernetes_namespace.nginx.metadata[0].name
    source_namespace  = kubernetes_namespace.flux.metadata[0].name
    configmap_hecksum = sha256(kubernetes_config_map_v1.nginx_helm_values.data["values.yaml"])
    configmap_name    = kubernetes_config_map_v1.nginx_helm_values.metadata[0].name
    semver            = "^4.13.2"
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

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
