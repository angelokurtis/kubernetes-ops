resource "kubectl_manifest" "istio_operator_helm_release" {
  yaml_body = <<YAML
apiVersion: helm.toolkit.fluxcd.io/v2beta1
kind: HelmRelease
metadata:
  name: istio-operator
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  values:
    operatorNamespace: ${kubernetes_namespace.istio.metadata[0].name}
    watchedNamespaces: ${kubernetes_namespace.istio.metadata[0].name}
    hub: docker.io/istio
    tag: ${local.istio.version}-distroless
  chart:
    spec:
      chart: manifests/charts/istio-operator
      reconcileStrategy: Revision
      sourceRef:
        kind: GitRepository
        name: istio
        namespace: default
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.istio_git_repository
  ]
}

resource "kubectl_manifest" "istio" {
  yaml_body = <<YAML
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: istio
  namespace: ${kubernetes_namespace.istio.metadata[0].name}
spec:
  profile: demo
  revision: "${replace(local.istio.version, ".", "-")}"
  components:
    egressGateways:
      - enabled: false
        name: istio-egressgateway
    ingressGateways:
      - enabled: true
        k8s:
          nodeSelector:
            ingress-ready: "true"
          service:
            ports:
              - name: status-port
                nodePort: 30002
                port: 15021
                targetPort: 15021
              - name: http2
                nodePort: 30000
                port: 80
                targetPort: 8080
              - name: https
                nodePort: 30001
                port: 443
                targetPort: 8443
        name: istio-ingressgateway
  values:
    gateways:
      istio-ingressgateway:
        type: NodePort
    global:
      istioNamespace: ${kubernetes_namespace.istio.metadata[0].name}
      defaultPodDisruptionBudget:
        enabled: false
      logging:
        level: default:debug
      proxy:
        componentLogLevel: misc:debug
        logLevel: debug
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.istio_operator_helm_release,
    kubernetes_job_v1.wait_istio_operator
  ]
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name   = local.istio.namespace
    labels = { istio-injection = "disabled" }
  }
}
