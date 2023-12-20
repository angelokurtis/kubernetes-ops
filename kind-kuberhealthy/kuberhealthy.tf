locals {
  kuberhealthy_crds = [
    "customresourcedefinition.apiextensions.k8s.io/khchecks.comcast.github.io",
    "customresourcedefinition.apiextensions.k8s.io/khjobs.comcast.github.io",
    "customresourcedefinition.apiextensions.k8s.io/khstates.comcast.github.io",
  ]
}

resource "kubectl_manifest" "git_repository_kuberhealthy" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: kuberhealthy
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://github.com/kuberhealthy/kuberhealthy
      ref:
        semver: ^2.7.1
      ignore: |
        # exclude all
        /*
        # include charts dir
        !/deploy/helm/kuberhealthy
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_kuberhealthy" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: kuberhealthy
      namespace: ${kubernetes_namespace.kuberhealthy.metadata[0].name}
    spec:
      chart:
        spec:
          chart: deploy/helm/kuberhealthy
          sourceRef:
            kind: GitRepository
            name: kuberhealthy
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.kuberhealthy_helm_values.metadata[0].name}
      interval: 60s
      dependsOn:
        - name: nginx
          namespace: ${kubernetes_namespace.nginx.metadata[0].name}
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "kuberhealthy_helm_values" {
  metadata {
    name      = "kuberhealthy-helm-values"
    namespace = kubernetes_namespace.kuberhealthy.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      prometheus          = { enabled = true }
      podDisruptionBudget = { enabled = false }
    })
  }
}

resource "kubernetes_job_v1" "wait_kuberhealthy_crd" {
  metadata {
    name      = "wait-kuberhealthy-crd"
    namespace = kubernetes_namespace.kuberhealthy.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_kuberhealthy_crd.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = flatten(["wait", "--for=condition=Established", local.kuberhealthy_crds, "--timeout", "10m"])
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
    kubectl_manifest.helm_release_kuberhealthy,
    kubernetes_cluster_role_binding_v1.wait_kuberhealthy_crd,
  ]
}

resource "kubernetes_service_account_v1" "wait_kuberhealthy_crd" {
  metadata {
    name      = "wait-kuberhealthy-crd"
    namespace = kubernetes_namespace.kuberhealthy.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "wait_kuberhealthy_crd" {
  metadata {
    name = "wait-kuberhealthy-crd"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_kuberhealthy_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_kuberhealthy_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "kuberhealthy" {
  metadata { name = "kuberhealthy" }
}
