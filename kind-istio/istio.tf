resource "helm_release" "istio_base" {
  name = "istio-base"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-base-1.1.0.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  timeout = 120
}

resource "helm_release" "istiod" {
  name = "istiod"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-discovery-1.2.0.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  timeout = 120

  values = [ yamlencode({ "global":{ "hub": var.istio_hub, "tag": var.istio_tag } }) ]

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_ingress" {
  name = "istio-ingress"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-ingress-1.1.0.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  timeout = 120

  values = [ yamlencode({ "global":{ "hub": var.istio_hub, "tag": var.istio_tag } }) ]

  depends_on = [
    helm_release.istio_base
  ]
}

resource "helm_release" "istio_egress" {
  name = "istio-egress"
  chart = "https://s3-sa-east-1.amazonaws.com/charts.kurtis/istio-egress-1.1.0.tgz"
  namespace = kubernetes_namespace.istio_system.metadata[0].name
  timeout = 120

  values = [ yamlencode({ "global":{ "hub": var.istio_hub, "tag": var.istio_tag } }) ]

  depends_on = [
    helm_release.istio_base
  ]
}
