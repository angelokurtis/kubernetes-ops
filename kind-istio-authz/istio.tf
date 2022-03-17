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
      sourceRef:
        kind: GitRepository
        name: istio
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
    kubernetes_job_v1.wait_istio_crds
  ]
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name   = local.istio.namespace
    labels = { istio-injection = "disabled" }
  }
}

resource "kubernetes_service_account_v1" "istio_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
}

resource "kubernetes_role_v1" "istio_helmreleases_reader" {
  metadata {
    name      = "istio-helmreleases-reader"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_istio_helmreleases_reader" {
  metadata {
    name      = "kubectl-istio-helmreleases-reader"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.istio_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.istio_kubectl.metadata[0].name
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
}

resource "kubernetes_job_v1" "wait_istio_crds" {
  metadata {
    name      = "wait-istio-crds"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.istio_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = ["wait", "--for=condition=Ready", "helmrelease/istio-operator", "--timeout", local.default_timeouts]
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = local.default_timeouts
    update = local.default_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.kubectl_istio_helmreleases_reader,
    kubectl_manifest.istio_operator_helm_release,
  ]
}
