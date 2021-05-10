data "kustomization_overlay" "contour" {
  resources = [ "https://github.com/projectcontour/contour/examples/render?ref=v1.15.0" ]

  patches {
    patch = yamlencode([
      {
        op = "replace"
        path = "/spec/template/spec/nodeSelector"
        value = {
          "ingress-ready":"true"
        }
      },
      {
        op = "replace"
        path = "/spec/template/spec/tolerations"
        value = [{
          effect = "NoSchedule"
          key = "node-role.kubernetes.io/master"
          operator = "Equal"
        }]
      }
    ])
    target = {
      kind = "DaemonSet"
      label_selector = "app=envoy"
    }
  }
}

resource "kustomization_resource" "contour" {
  for_each = data.kustomization_overlay.contour.ids
  manifest = data.kustomization_overlay.contour.manifests[each.value]
}