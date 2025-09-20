resource "kubectl_manifest" "git_repository_weave_gitops" {
  yaml_body = templatefile("${path.module}/manifests/gitrepositories.source.toolkit.fluxcd.io/weave-gitops.yaml", {
    namespace = kubernetes_namespace.flux.metadata[0].name
    semver    = "^0.38.0"
  })

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_weave_gitops" {
  yaml_body = templatefile("${path.module}/manifests/helmreleases.helm.toolkit.fluxcd.io/gitops-server.yaml", {
    namespace         = kubernetes_namespace.weave_gitops.metadata[0].name
    source_namespace  = kubernetes_namespace.flux.metadata[0].name
    configmap_hecksum = sha256(kubernetes_config_map_v1.weave_gitops_helm_values.data["values.yaml"])
    configmap_name    = kubernetes_config_map_v1.weave_gitops_helm_values.metadata[0].name
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "weave_gitops_helm_values" {
  metadata {
    name      = "gitops-server-helm-values"
    namespace = kubernetes_namespace.weave_gitops.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      networkPolicy = { create = false }
      adminUser = {
        create       = true
        username     = "admin"
        passwordHash = null_resource.weave_gitops_admin_password.triggers.password
      }
      ingress = {
        className = "nginx"
        enabled   = true
        hosts = [
          {
            host  = "gitops.${local.cluster_host}"
            paths = [{ path = "/", pathType = "Prefix" }]
          },
        ]
      }
    })
  }
}

resource "null_resource" "weave_gitops_admin_password" {
  triggers = {
    password = bcrypt("admin")
  }

  lifecycle {
    ignore_changes = [triggers["password"]]
  }
}

resource "kubernetes_namespace" "weave_gitops" {
  metadata { name = "weave-gitops" }
}
