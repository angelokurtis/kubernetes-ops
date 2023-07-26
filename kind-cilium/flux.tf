locals {
  flux_crds = [
    "customresourcedefinition.apiextensions.k8s.io/alerts.notification.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/buckets.source.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/gitrepositories.source.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/helmcharts.source.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/helmreleases.helm.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/helmrepositories.source.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/imagepolicies.image.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/imagerepositories.image.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/imageupdateautomations.image.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/kustomizations.kustomize.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/ocirepositories.source.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/providers.notification.toolkit.fluxcd.io",
    "customresourcedefinition.apiextensions.k8s.io/receivers.notification.toolkit.fluxcd.io",
  ]
}

resource "helm_release" "flux" {
  repository = "https://fluxcd-community.github.io/helm-charts"
  chart      = "flux2"
  version    = "2.9.0"

  name      = "flux"
  namespace = kubernetes_namespace.flux.metadata[0].name
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
          args    = flatten(["wait", "--for=condition=Established", local.flux_crds, "--timeout", "10m"])
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
