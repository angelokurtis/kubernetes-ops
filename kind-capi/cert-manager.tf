locals {
  cert_manager_crds = [
    "customresourcedefinition.apiextensions.k8s.io/certificaterequests.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/certificates.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/challenges.acme.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/clusterissuers.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/issuers.cert-manager.io",
    "customresourcedefinition.apiextensions.k8s.io/orders.acme.cert-manager.io",
  ]
}

resource "kubectl_manifest" "helm_repository_jetstack" {
  yaml_body = templatefile("${path.module}/manifests/helmrepositories.source.toolkit.fluxcd.io/jetstack.yaml", {
    namespace = kubernetes_namespace.flux.metadata[0].name
  })

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_cert_manager" {
  yaml_body = templatefile("${path.module}/manifests/helmreleases.helm.toolkit.fluxcd.io/cert-manager.yaml", {
    namespace         = kubernetes_namespace.cert_manager.metadata[0].name
    source_namespace  = kubernetes_namespace.flux.metadata[0].name
    configmap_hecksum = sha256(kubernetes_config_map_v1.cert_manager_helm_values.data["values.yaml"])
    configmap_name    = kubernetes_config_map_v1.cert_manager_helm_values.metadata[0].name
    semver            = "^v1.19.0"
  })

  wait_for {
    condition {
      type   = "Ready"
      status = "True"
    }
  }

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "cert_manager_helm_values" {
  metadata {
    name      = "cert-manager-helm-values"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      installCRDs = true
      prometheus  = { enabled = false }
    })
  }
}

resource "kubernetes_job_v1" "wait_cert_manager_crd" {
  metadata {
    name      = "wait-cert-manager-crd"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_cert_manager_crd.metadata[0].name
        container {
          name  = "kubectl"
          image = "rancher/kubectl:${data.kubectl_server_version.current.version}"
          args  = flatten(["wait", "--for=condition=Established", local.cert_manager_crds, "--timeout", "10m"])
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
    kubectl_manifest.helm_release_cert_manager,
    kubernetes_cluster_role_binding_v1.wait_cert_manager_crd,
  ]
}

resource "kubernetes_service_account_v1" "wait_cert_manager_crd" {
  metadata {
    name      = "wait-cert-manager-crd"
    namespace = kubernetes_namespace.cert_manager.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "wait_cert_manager_crd" {
  metadata {
    name = "wait-cert-manager-crd"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_cert_manager_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_cert_manager_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "cert_manager" {
  metadata { name = "cert-manager" }
}
