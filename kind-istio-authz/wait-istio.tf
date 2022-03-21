resource "kubernetes_role_v1" "istio_install_reader" {
  metadata {
    name      = "istio-install-reader"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  rule {
    api_groups = ["install.istio.io"]
    resources  = ["istiooperators"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_istio_install_reader" {
  metadata {
    name      = "kubectl-istio-install-reader"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.istio_install_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.istio_kubectl.metadata[0].name
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
}

resource "kubernetes_job_v1" "wait_istio" {
  metadata {
    name      = "wait-istio"
    namespace = kubernetes_namespace.istio.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.istio_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:1.23"
          args  = [
            "wait", "--for=jsonpath={.status.status}=HEALTHY", "istiooperator.install.istio.io/istio",
            "--timeout", local.default_timeouts
          ]
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
    kubernetes_role_binding_v1.kubectl_istio_install_reader,
    kubectl_manifest.istio,
  ]
}
