resource "kubectl_manifest" "helm_repository_capi_operator" {
  yaml_body = templatefile("${path.module}/manifests/helmrepositories.source.toolkit.fluxcd.io/capi-operator.yaml", {
    namespace = kubernetes_namespace.flux.metadata[0].name
  })

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_capi_operator" {
  yaml_body = templatefile("${path.module}/manifests/helmreleases.helm.toolkit.fluxcd.io/capi-operator.yaml", {
    namespace         = kubernetes_namespace.capi.metadata[0].name
    source_namespace  = kubernetes_namespace.flux.metadata[0].name
    configmap_hecksum = sha256(kubernetes_config_map_v1.capi_operator_helm_values.data["values.yaml"])
    configmap_name    = kubernetes_config_map_v1.capi_operator_helm_values.metadata[0].name
    semver            = "^0.23.0"
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [
    kubernetes_job_v1.wait_flux_crd,
    kubernetes_job_v1.wait_cert_manager_crd,
  ]
}

resource "kubernetes_config_map_v1" "capi_operator_helm_values" {
  metadata {
    name      = "capi-operator-helm-values"
    namespace = kubernetes_namespace.capi.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      core = {
        cluster-api = {
          enabled         = true
          createNamespace = false
          namespace       = kubernetes_namespace.capi.metadata[0].name
        }
      }
    })
  }
}

resource "kubernetes_secret_v1" "proxmox_credentials" {
  metadata {
    name      = "proxmox-credentials"
    namespace = kubernetes_namespace.capi.metadata[0].name
  }
  data = {
    PROXMOX_URL    = "https://pve.example:8006/api2/json"
    PROXMOX_TOKEN  = "root@pam!capi"
    PROXMOX_SECRET = ""
  }
}

resource "kubernetes_namespace" "capi" {
  metadata { name = "capi" }
}
