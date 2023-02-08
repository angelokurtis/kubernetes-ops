locals {
  wait_timeouts = "10m"
}

resource "kubernetes_job_v1" "wait_helm_release" {
  for_each = local.helm_releases

  metadata {
    name      = "wait-${each.key}"
    namespace = each.value.namespace
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_helm_release[each.key].metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = ["wait", "--for=condition=Ready", "helmrelease/${each.key}", "--timeout", local.wait_timeouts]
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = local.wait_timeouts
    update = local.wait_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.helm_release_reader,
    kubectl_manifest.helm_release,
  ]
}

resource "kubernetes_service_account_v1" "wait_helm_release" {
  for_each = local.helm_releases

  metadata {
    name      = "wait-${each.key}"
    namespace = each.value.namespace
  }
}

resource "kubernetes_role_binding_v1" "helm_release_reader" {
  for_each = local.helm_releases

  metadata {
    name      = "wait-${each.key}-helmreleases-reader"
    namespace = each.value.namespace
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.helmreleases_reader[each.value.namespace].metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_helm_release[each.key].metadata[0].name
    namespace = kubernetes_service_account_v1.wait_helm_release[each.key].metadata[0].namespace
  }
}

resource "kubernetes_role_v1" "helmreleases_reader" {
  for_each = toset(distinct([for helm_release in local.helm_releases : helm_release.namespace]))

  metadata {
    name      = "helmreleases-reader"
    namespace = each.key
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.kafka]
}
