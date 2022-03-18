resource "kubernetes_service_account_v1" "keycloak_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}

resource "kubernetes_role_v1" "postgresql_helmreleases_reader" {
  metadata {
    name      = "postgresql-helmreleases-reader"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_role_binding_v1" "kubectl_postgresql_helmreleases_reader" {
  metadata {
    name      = "kubectl-postgresql-helmreleases-reader"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.postgresql_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}

resource "kubernetes_job_v1" "wait_postgresql" {
  metadata {
    name      = "wait-postgresql"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = [
            "wait", "--for=condition=Ready", "helmrelease/postgresql",
            "--timeout", local.default_timeouts,
            "-n", kubernetes_namespace.postgresql.metadata[0].name
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
    kubernetes_role_binding_v1.kubectl_postgresql_helmreleases_reader,
    kubectl_manifest.postgresql_helm_release,
  ]
}
