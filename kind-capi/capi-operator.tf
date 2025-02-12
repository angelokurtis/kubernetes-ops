resource "kubectl_manifest" "helm_repository_capi_operator" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: capi-operator
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://kubernetes-sigs.github.io/cluster-api-operator
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_capi_operator" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: capi-operator
      namespace: ${kubernetes_namespace.capi_operator.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.capi_operator_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: cluster-api-operator
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: capi-operator
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.capi_operator_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [
    kubernetes_job_v1.wait_flux_crd,
    kubernetes_job_v1.wait_cert_manager_crd,
  ]
}

resource "kubernetes_config_map_v1" "capi_operator_helm_values" {
  metadata {
    name      = "capi-operator-helm-values"
    namespace = kubernetes_namespace.capi_operator.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      cert-manager = { enabled = true }
      configSecret = {
        name      = kubernetes_secret_v1.proxmox_credentials.metadata[0].name
        namespace = kubernetes_secret_v1.proxmox_credentials.metadata[0].namespace
      }
    })
  }
}

resource "kubernetes_secret_v1" "proxmox_credentials" {
  metadata {
    name      = "proxmox-credentials"
    namespace = kubernetes_namespace.capi_operator.metadata[0].name
  }
  data = {
    PROXMOX_URL      = "https://X.X.X.X:8006/api2/json"
    PROXMOX_USER     = "user@pam"
    PROXMOX_PASSWORD = ""
  }
}

resource "kubernetes_namespace" "capi_operator" {
  metadata { name = "capi-operator" }
}

# helm install capi-operator capi-operator/cluster-api-operator
#   --create-namespace
#   -n capi-operator-system
#   --set infrastructure=docker
#   --set cert-manager.enabled=true
#   --set configSecret.name=${CREDENTIALS_SECRET_NAME}
#   --set configSecret.namespace=${CREDENTIALS_SECRET_NAMESPACE}
#   --wait --timeout 90s
