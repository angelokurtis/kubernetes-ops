resource "kubectl_manifest" "traefik_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: traefik
  namespace: ${kubernetes_namespace.traefik.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  chart:
    spec:
      chart: traefik
      sourceRef:
        kind: HelmRepository
        name: traefik
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  values:
    ingressClass:
      enabled: true
      isDefaultClass: true
    ports:
      traefik:
        expose: true
        nodePort: 32090
      web:
        nodePort: 32080
      websecure:
        nodePort: 32443
    providers:
      kubernetesCRD:
        namespaces:
          - default
          - ${kubernetes_namespace.traefik.metadata[0].name}
      kubernetesIngress:
        namespaces:
          - default
          - ${kubernetes_namespace.traefik.metadata[0].name}
        publishedService:
          enabled: true
    service:
      type: NodePort
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.traefik_helm_repository
  ]
}

resource "kubernetes_namespace" "traefik" {
  metadata { name = var.traefik_namespace }
}
