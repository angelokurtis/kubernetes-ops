locals {
  apirator_crds = [
    "crd/apimocks.apirator.io",
  ]
}

resource "kubectl_manifest" "git_repository_apirator" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: apirator
      namespace: ${kubernetes_namespace.apirator.metadata[0].name}
    spec:
      interval: 60s
      url: https://github.com/apirator/apirator
      ref:
        semver: ">= 1.0.0"
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "kustomization_apirator" {
  yaml_body = <<-YAML
    apiVersion: kustomize.toolkit.fluxcd.io/v1
    kind: Kustomization
    metadata:
      name: apirator
      namespace: ${kubernetes_namespace.apirator.metadata[0].name}
    spec:
      interval: 60s
      prune: true
      sourceRef:
        kind: GitRepository
        name: apirator
      path: config/default
      targetNamespace: ${kubernetes_namespace.apirator.metadata[0].name}
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_job_v1" "wait_apirator_crd" {
  metadata {
    name      = "wait-apirator-crd"
    namespace = kubernetes_namespace.apirator.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_apirator_crd.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = flatten(["wait", "--for=condition=Established", local.apirator_crds, "--timeout", "10m"])
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
    kubectl_manifest.git_repository_apirator,
    kubernetes_cluster_role_binding_v1.crd_readers,
  ]
}

resource "kubernetes_service_account_v1" "wait_apirator_crd" {
  metadata {
    name      = "wait-apirator-crd"
    namespace = kubernetes_namespace.apirator.metadata[0].name
  }
}

resource "kubernetes_namespace" "apirator" {
  metadata { name = "apirator" }
}
