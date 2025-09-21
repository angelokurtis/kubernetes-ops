resource "kubectl_manifest" "git_repository_keycloak_operator" {
  yaml_body = templatefile("${path.module}/manifests/gitrepositories.source.toolkit.fluxcd.io/keycloak-k8s-resources.yaml", {
    namespace = kubernetes_namespace.flux.metadata[0].name
    semver    = "^26.3.4"
  })

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "kustomization_keycloak_operator" {
  yaml_body = templatefile("${path.module}/manifests/kustomizations.kustomize.toolkit.fluxcd.io/keycloak-operator.yaml", {
    namespace            = kubernetes_namespace.keycloak.metadata[0].name
    source_ref_namespace = kubernetes_namespace.flux.metadata[0].name
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_namespace" "keycloak" {
  metadata { name = "keycloak" }
}
