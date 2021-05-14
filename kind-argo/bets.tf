data "kustomization_overlay" "bets" {
  resources = [
    "${path.root}/bets"
  ]

  namespace = kubernetes_namespace.ops.metadata[0].name

  patches {
    patch = yamlencode([{
      op = "replace", path = "/spec/destination/namespace"
      value = kubernetes_namespace.bets.metadata[0].name
    }])
    target = {
      apiVersion: "argoproj.io/v1alpha1",
      kind = "Application",
      label_selector = "app.kubernetes.io/part-of=bets-system"
    }
  }
}

resource "kustomization_resource" "bets" {
  for_each = data.kustomization_overlay.bets.ids
  manifest = data.kustomization_overlay.bets.manifests[each.value]

  depends_on = [
    helm_release.argocd
  ]
}

resource "kubernetes_namespace" "bets" {
  metadata {
    name = "bets"
    annotations = {
      "linkerd.io/inject" = "enabled"
    }
  }
}
