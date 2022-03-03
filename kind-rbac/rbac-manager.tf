resource "kubectl_manifest" "rbac_manager_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: rbac-manager
  namespace: ${kubernetes_namespace.rbac_manager.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  values:
    image:
      repository: quay.io/reactiveops/rbac-manager
      tag: v${local.rbac_manager.version}
      pullPolicy: IfNotPresent
  chart:
    spec:
      chart: rbac-manager
      sourceRef:
        kind: HelmRepository
        name: fairwinds
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.fairwinds_helm_repository
  ]
}
