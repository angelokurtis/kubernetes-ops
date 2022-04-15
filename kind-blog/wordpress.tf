resource "kubectl_manifest" "wordpress_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: wordpress
  namespace: ${kubernetes_namespace.wordpress.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  values:
    ingress:
      enabled: true
      ingressClassName: "nginx"
      hostname: wordpress.${local.cluster_host}
  chart:
    spec:
      chart: wordpress
      sourceRef:
        kind: HelmRepository
        name: bitnami
        namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  dependsOn:
    - name: ingress-nginx
      namespace: ${kubernetes_namespace.ingress_nginx.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.bitnami_helm_repository,
  ]
}

resource "kubernetes_namespace" "wordpress" {
  metadata { name = "wordpress" }
}
