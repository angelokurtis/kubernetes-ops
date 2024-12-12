resource "kubectl_manifest" "git_repository_angelokurtis_provider_github" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1
    kind: GitRepository
    metadata:
      name: provider-github
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://github.com/angelokurtis/provider-github
      ref:
        branch: main
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "kustomization_crossplane_provider_github" {
  yaml_body = <<-YAML
    apiVersion: kustomize.toolkit.fluxcd.io/v1
    kind: Kustomization
    metadata:
      name: crossplane-provider-github
      namespace: ${kubernetes_namespace.crossplane.metadata[0].name}
    spec:
      interval: 60s
      targetNamespace: ${kubernetes_namespace.crossplane.metadata[0].name}
      sourceRef:
        kind: GitRepository
        name: provider-github
        namespace: ${kubernetes_namespace.flux.metadata[0].name}
      path: "./package/crds"
      prune: true
      timeout: 1m
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}
