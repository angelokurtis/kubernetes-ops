resource "kubectl_manifest" "helm_release_rabbitmq" {
  yaml_body = <<-YAML
    apiVersion: helm.toolkit.fluxcd.io/v2beta1
    kind: HelmRelease
    metadata:
      name: rabbitmq
      namespace: ${kubernetes_namespace.rabbitmq.metadata[0].name}
    spec:
      chart:
        spec:
          chart: rabbitmq
          reconcileStrategy: ChartVersion
          sourceRef:
            kind: HelmRepository
            name: bitnami
            namespace: ${kubernetes_namespace.flux.metadata[0].name}
      valuesFrom:
        - kind: ConfigMap
          name: ${kubernetes_config_map_v1.rabbitmq_values.metadata[0].name}
      interval: 60s
  YAML

  depends_on = [kubernetes_job_v1.wait_flux_crd]
}

resource "kubernetes_config_map_v1" "rabbitmq_values" {
  metadata {
    name      = "rabbitmq-values"
    namespace = kubernetes_namespace.rabbitmq.metadata[0].name
  }
  data = {
    "values.yaml" = yamlencode({
      ingress = {
        enabled          = true
        hostname         = "rabbitmq.lvh.me"
        ingressClassName = "nginx"
        path             = "/"
        pathType         = "ImplementationSpecific"
      }
      metrics          = { enabled = true }
      service          = { type = "NodePort" }
      communityPlugins = "https://github.com/rabbitmq/rabbitmq-delayed-message-exchange/releases/download/v3.12.0/rabbitmq_delayed_message_exchange-3.12.0.ez"
      extraPlugins     = "rabbitmq_delayed_message_exchange"
    })
  }
}

resource "kubernetes_namespace" "rabbitmq" {
  metadata { name = "rabbitmq" }
}
