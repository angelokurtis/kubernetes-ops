locals {
  charlescd = { version = "1.0.1" }
}

resource "helm_release" "charlescd" {
  name = "charlescd"
  namespace = kubernetes_namespace.cd.metadata[0].name

  repository = "https://charts.kurtis.dev.br/"
  chart = "charlescd"
  version = "0.7.0"

  values = [
    yamlencode({
      hostGlobal = "http://charles.${local.cluster_domain}"
      CharlesApplications = {
        ui = { image = { tag = local.charlescd.version } }
        circleMatcher = { image = { tag = local.charlescd.version } }
        gate = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_moove"]["database"]
            user = local.database["charlescd_moove"]["user"]
            password = local.database["charlescd_moove"]["password"]
          }
          image = { tag = local.charlescd.version }
        }
        butler = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_butler"]["database"]
            user = local.database["charlescd_butler"]["user"]
            password = local.database["charlescd_butler"]["password"]
          }
          image = { tag = local.charlescd.version }
        }
        compass = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_compass"]["database"]
            user = local.database["charlescd_compass"]["user"]
            password = local.database["charlescd_compass"]["password"]
          }
          moove = {
            database = {
              host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
              name = local.database["charlescd_moove"]["database"]
              user = local.database["charlescd_moove"]["user"]
              password = local.database["charlescd_moove"]["password"]
            }
          }
          image = { tag = local.charlescd.version }
        }
        moove = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_moove"]["database"]
            user = local.database["charlescd_moove"]["user"]
            password = local.database["charlescd_moove"]["password"]
          }
          image = { tag = local.charlescd.version }
        }
        villager = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_villager"]["database"]
            user = local.database["charlescd_villager"]["user"]
            password = local.database["charlescd_villager"]["password"]
          }
          image = { tag = local.charlescd.version }
        }
      }
      ingress = { enabled = false }
      envoy = { enabled = false }
      postgresql = { enabled = false }
      redis = { enabled = false }
      keycloak = { enabled = false }
      nginx_ingress_controller = { enabled = false }
      rabbitmq = { enabled = false }
    })
  ]
}
