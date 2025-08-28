locals {
  cert_manager_crds = [
    "customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io",
  ]
}

resource "kubectl_manifest" "helm_repository_jetstack" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: jetstack
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://charts.jetstack.io
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_cert_manager" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: cert-manager
      namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
      annotations:
        "checksum/config": ${sha256(kubernetes_config_map_v1.cert_manager_helm_values.data["values.yaml"])}
    spec:
      chart:
        spec:
          chart: cert-manager
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: jetstack
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.cert_manager_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "cert_manager_helm_values" {
  metadata {
    name      = "cert-manager-helm-values"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      installCRDs = true
      prometheus  = { enabled = false }
    })
  }
}

resource "kubernetes_service_account_v1" "wait_cert_manager_crd" {
  metadata {
    name      = "wait-cert-manager-crd"
    namespace = kubernetes_namespace.flux.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "wait_cert_manager_crd" {
  metadata {
    name = "wait-cert-manager-crd"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_cert_manager_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_cert_manager_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}
