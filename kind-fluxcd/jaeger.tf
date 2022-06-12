resource "kubectl_manifest" "jaeger_helm_repository" {
  yaml_body = <<YAML
apiVersion: source.toolkit.fluxcd.io/v1beta1
kind: HelmRepository
metadata:
  name: jaeger
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  url: https://jaegertracing.github.io/helm-charts
YAML

  depends_on = [kubectl_manifest.fluxcd]
}

resource "kubectl_manifest" "jaeger_operator_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: jaeger-operator
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  interval: ${local.flux.default_interval}
  chart:
    spec:
      chart: jaeger-operator
      sourceRef:
        kind: HelmRepository
        name: jaeger
  values:
    rbac:
      clusterRole: true
  dependsOn:
    - name: cert-manager
      namespace: ${kubernetes_namespace.cert_manager.metadata[0].name}
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_helm_repository
  ]
}

resource "kubectl_manifest" "jaeger" {
  yaml_body = <<YAML
apiVersion: jaegertracing.io/v1
kind: Jaeger
metadata:
  name: jaeger
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  ingress:
    enabled: true
    hosts:
      - ${local.jaeger.query.host}
    ingressClassName: traefik
  storage:
    type: memory
  strategy: allinone
  allInOne:
    image: jaegertracing/all-in-one:1.35.1
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_operator_helm_release
  ]
}

resource "kubectl_manifest" "jaeger_collector_ingress" {
  yaml_body = <<YAML
apiVersion: networking.k8s.io/v1
kind: Ingress
metadata:
  name: jaeger-collector
  namespace: ${kubernetes_namespace.jaeger.metadata[0].name}
spec:
  ingressClassName: traefik
  rules:
    - host: ${local.jaeger.collector.host}
      http:
        paths:
          - backend:
              service:
                name: jaeger-collector
                port:
                  number: 14268
            pathType: ImplementationSpecific
YAML

  depends_on = [kubectl_manifest.jaeger]
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = var.jaeger_namespace }
}
