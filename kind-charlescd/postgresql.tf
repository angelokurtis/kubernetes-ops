//locals {
//  charlescd = { version = "1.0.1" }
//}
//
//resource "helm_release" "charlescd" {
//  name = "charlescd"
//  namespace = kubernetes_namespace.cd.metadata[0].name
//
//  repository = "https://charts.kurtis.dev.br/"
//  chart = "charlescd"
//  version = "0.7.0"
//
//  values = [
//    yamlencode({
//      hostGlobal = "http://charles.${local.cluster_domain}"
//      CharlesApplications = {
//        butler = { image = { tag = local.charlescd.version } }
//        circleMatcher = { image = { tag = local.charlescd.version } }
//        compass = { image = { tag = local.charlescd.version } }
//        gate = { image = { tag = local.charlescd.version } }
//        moove = { image = { tag = local.charlescd.version } }
//        ui = { image = { tag = local.charlescd.version } }
//        villager = { image = { tag = local.charlescd.version } }
//      }
//      ingress = { enabled = false }
//      envoy = { enabled = false }
//      postgresql = { enabled = false }
//      redis = { enabled = false }
//      keycloak = { enabled = false }
//      nginx_ingress_controller = { enabled = false }
//      rabbitmq = { enabled = false }
//    })
//  ]
//}
