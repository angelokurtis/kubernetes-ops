resource "kubectl_manifest" "helm_repository_arc" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: actions-runner-controller
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      type: "oci"
      interval: 60s
      url: oci://ghcr.io/actions/actions-runner-controller-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_gha_runner_scale_set_controller" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: gha-runner-scale-set-controller
      namespace: ${kubernetes_namespace.arc.metadata[0].name}
    spec:
      chart:
        spec:
          chart: gha-runner-scale-set-controller
          version: "^0.9.0"
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: actions-runner-controller
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.arc_helm_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "arc_helm_values" {
  metadata {
    name      = "gha-runner-scale-set-controller-helm-values"
    namespace = kubernetes_namespace.arc.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
    })
  }
}

resource "kubernetes_namespace" "arc" {
  metadata { name = "arc" }
}
