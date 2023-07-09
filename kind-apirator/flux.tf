locals {
  flux_crds = [
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
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = flatten(["wait", "--for=condition=Established", local.flux_crds, "--timeout", "10m"])
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = "10m"
    update = "10m"
  }

  depends_on = [
    helm_release.flux,
    kubernetes_cluster_role_binding_v1.crd_readers,
  ]
}

resource "kubernetes_service_account_v1" "wait_flux_crd" {
  metadata {
    name      = "wait-flux-crd"
    namespace = kubernetes_namespace.flux.metadata[0].name
  }
}

resource "kubernetes_namespace" "flux" {
  metadata { name = "flux" }
}
