resource "kubernetes_service_account_v1" "tekton_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.tekton_operator.metadata[0].name
  }
}

resource "kubernetes_role_v1" "tekton_kustomization_reader" {
  metadata {
    name      = "tekton-kustomization-reader"
    namespace = kubernetes_namespace.tekton_operator.metadata[0].name
  }
  rule {
    api_groups = ["kustomize.toolkit.fluxcd.io"]
    resources  = ["kustomizations"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_tekton_kustomization_reader" {
  metadata {
    name      = "kubectl-tekton-kustomization-reader"
    namespace = kubernetes_namespace.tekton_operator.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.tekton_kustomization_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.tekton_kubectl.metadata[0].name
    namespace = kubernetes_namespace.tekton_operator.metadata[0].name
  }
}

resource "kubernetes_job_v1" "wait_tekton_operator" {
  metadata {
    name      = "wait-tekton-operator"
    namespace = kubernetes_namespace.tekton_operator.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.tekton_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:1.23"
          args  = [
            "wait", "--for=condition=Ready", "kustomization.kustomize.toolkit.fluxcd.io/tekton-operator",
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
    kubernetes_role_binding_v1.kubectl_tekton_kustomization_reader,
    kubectl_manifest.tekton_operator_kustomization,
  ]
}
