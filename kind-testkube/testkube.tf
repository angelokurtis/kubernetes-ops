locals {
  testkube_crds = [
    "customresourcedefinition.apiextensions.k8s.io/executors.executor.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/scripts.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/testexecutions.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/tests.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/testsources.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/testsuiteexecutions.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/testsuites.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/testtriggers.tests.testkube.io",
    "customresourcedefinition.apiextensions.k8s.io/webhooks.executor.testkube.io",
  ]
}

resource "kubectl_manifest" "helm_repository_kubeshop" {
  yaml_body = <<-YAML
    apiVersion: source.toolkit.fluxcd.io/v1beta2
    kind: HelmRepository
    metadata:
      name: kubeshop
      namespace: ${kubernetes_namespace.flux.metadata[0].name}
    spec:
      interval: 60s
      url: https://kubeshop.github.io/helm-charts
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubectl_manifest" "helm_release_testkube" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: testkube
      namespace: ${kubernetes_namespace.testkube.metadata[0].name}
    spec:
      chart:
        spec:
          chart: testkube
          version: "~1.16.0"
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: kubeshop
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.testkube.metadata[0].name}
      interval: 60s
      dependsOn:
        - name: nginx
          namespace: ${kubernetes_namespace.nginx.metadata[0].name}
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "testkube" {
  metadata {
    name      = "testkube"
    namespace = kubernetes_namespace.testkube.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      testkube-api = {
        uiIngress = {
          enabled   = true
          className = "nginx"
          path      = "/", hosts = ["testkube-api.${local.cluster_host}"]
        }
      }
      testkube-dashboard = {
        ingress = {
          enabled   = true
          className = "nginx"
          path      = "/", hosts = ["testkube.${local.cluster_host}"]
        }
        apiServerEndpoint = "testkube-api.${local.cluster_host}"
      }
    })
  }
}

resource "kubernetes_job_v1" "wait_testkube_crd" {
  metadata {
    name      = "wait-testkube-crd"
    namespace = kubernetes_namespace.testkube.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_testkube_crd.metadata[0].name
        container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          args  = flatten(["wait", "--for=condition=Established", local.testkube_crds, "--timeout", "10m"])
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
    kubectl_manifest.helm_release_testkube,
    kubernetes_cluster_role_binding_v1.wait_testkube_crd,
  ]
}

resource "kubernetes_service_account_v1" "wait_testkube_crd" {
  metadata {
    name      = "wait-testkube-crd"
    namespace = kubernetes_namespace.testkube.metadata[0].name
  }
}

resource "kubernetes_cluster_role_binding_v1" "wait_testkube_crd" {
  metadata {
    name = "wait-testkube-crd"
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_testkube_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_testkube_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "testkube" {
  metadata { name = "testkube" }
}
