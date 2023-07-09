locals {
  wait_timeouts = "10m"
  flux_crds     = [
    "crd/alerts.notification.toolkit.fluxcd.io",
    "crd/buckets.source.toolkit.fluxcd.io",
    "crd/gitrepositories.source.toolkit.fluxcd.io",
    "crd/helmcharts.source.toolkit.fluxcd.io",
    "crd/helmreleases.helm.toolkit.fluxcd.io",
    "crd/helmrepositories.source.toolkit.fluxcd.io",
    "crd/imagepolicies.image.toolkit.fluxcd.io",
    "crd/imagerepositories.image.toolkit.fluxcd.io",
    "crd/imageupdateautomations.image.toolkit.fluxcd.io",
    "crd/kustomizations.kustomize.toolkit.fluxcd.io",
    "crd/ocirepositories.source.toolkit.fluxcd.io",
    "crd/providers.notification.toolkit.fluxcd.io",
    "crd/receivers.notification.toolkit.fluxcd.io",
  ]
}

resource "helm_release" "flux" {
  repository       = "https://fluxcd-community.github.io/helm-charts"
  chart            = "flux2"
  name             = "flux"
  namespace        = kubernetes_namespace.flux.metadata[0].name
  create_namespace = true
}

resource "kubernetes_job_v1" "wait_flux_crd" {
  metadata {
    name      = "wait-flux-crd"
    namespace = kubernetes_namespace.flux.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_flux_crd.metadata[0].name
        container {
          name    = "kubectl"
          image   = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          command = ["/bin/sh", "-c"]
          args    = flatten(["wait", "--for=condition=Ready", local.flux_crds, "--timeout", local.wait_timeouts])
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
    helm_release.flux,
    kubernetes_role_binding_v1.wait_flux_crd,
  ]
}

resource "kubernetes_service_account_v1" "wait_flux_crd" {
  metadata {
    name      = "wait-flux-crd"
    namespace = kubernetes_namespace.flux.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "wait_flux_crd" {
  metadata {
    name      = "wait-flux-crd"
    namespace = kubernetes_namespace.flux.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_flux_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_flux_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "flux" {
  metadata { name = "flux" }
}

data "kubectl_server_version" "current" {
  depends_on = [kind_cluster.apirator]
}
