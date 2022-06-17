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
    image: jaegertracing/all-in-one:1.35.2
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.jaeger_operator_helm_release,
    kubernetes_job_v1.wait_jaeger_crds
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

resource "kubernetes_job_v1" "wait_jaeger_crds" {
  metadata {
    name      = "wait-jaeger-crds"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.jaeger_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = ["wait", "--for=condition=Ready", "helmrelease/jaeger-operator", "--timeout", local.default_timeouts]
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
    kubernetes_role_binding_v1.kubectl_jaeger_helmreleases_reader,
    kubectl_manifest.jaeger_operator_helm_release,
  ]
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.flux]
}

resource "kubernetes_service_account_v1" "jaeger_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
}

resource "kubernetes_role_v1" "jaeger_helmreleases_reader" {
  metadata {
    name      = "jaeger-helmreleases-reader"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_jaeger_helmreleases_reader" {
  metadata {
    name      = "kubectl-jaeger-helmreleases-reader"
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.jaeger_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.jaeger_kubectl.metadata[0].name
    namespace = kubernetes_namespace.jaeger.metadata[0].name
  }
}

resource "kubernetes_namespace" "jaeger" {
  metadata { name = var.jaeger_namespace }
}
