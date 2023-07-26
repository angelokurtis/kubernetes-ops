locals {
  cilium_crds = [
    "customresourcedefinition.apiextensions.k8s.io/ciliumclusterwidenetworkpolicies.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumendpoints.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumexternalworkloads.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumidentities.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumloadbalancerippools.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumnetworkpolicies.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumnodeconfigs.cilium.io",
    "customresourcedefinition.apiextensions.k8s.io/ciliumnodes.cilium.io",
  ]
}

resource "helm_release" "cilium" {
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = "1.13.4"

  name      = "cilium"
  namespace = kubernetes_namespace.cilium.metadata[0].name

  values = [
    yamlencode({
      cluster         = { name = "kind-${kind_cluster.cilium.name}" }
      ipam            = { mode = "kubernetes" }
      operator        = { replicas = 1 }
      serviceAccounts = {
        cilium   = { name = "cilium" }
        operator = { name = "cilium-operator" }
      }
      tunnel               = "vxlan"
      kubeProxyReplacement = "strict"
      ingressController    = {
        enabled          = true
        enforceHttps     = false
        loadbalancerMode = "shared"
        service          = {
          insecureNodePort = 30080
          secureNodePort   = 30443
          type             = "NodePort"
          loadBalancerIP   = "127.0.0.1"
        }
      }
    })
  ]
}

resource "kubernetes_job_v1" "wait_cilium_crd" {
  metadata {
    name      = "wait-cilium-crd"
    namespace = kubernetes_namespace.cilium.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.wait_cilium_crd.metadata[0].name
        container {
          name    = "kubectl"
          image   = "docker.io/bitnami/kubectl:${data.kubectl_server_version.current.major}.${data.kubectl_server_version.current.minor}"
          command = ["/bin/sh", "-c"]
          args    = flatten(["wait", "--for=condition=Established", local.cilium_crds, "--timeout", "10m"])
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
    kubernetes_role_binding_v1.wait_cilium_crd,
  ]
}

resource "kubernetes_service_account_v1" "wait_cilium_crd" {
  metadata {
    name      = "wait-cilium-crd"
    namespace = kubernetes_namespace.cilium.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "wait_cilium_crd" {
  metadata {
    name      = "wait-cilium-crd"
    namespace = kubernetes_namespace.cilium.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = kubernetes_cluster_role_v1.crd_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.wait_cilium_crd.metadata[0].name
    namespace = kubernetes_service_account_v1.wait_cilium_crd.metadata[0].namespace
  }
}

resource "kubernetes_namespace" "cilium" {
  metadata { name = "cilium" }
}
