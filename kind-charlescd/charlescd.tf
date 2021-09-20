locals {
  charlescd = { version = "1.0.1" }
}

resource "helm_release" "charlescd" {
  name = "charlescd"
  namespace = kubernetes_namespace.cd.metadata[0].name

  repository = "https://charts.kurtis.dev.br/"
  chart = "charlescd"
  version = "0.7.0"

  timeout = 10*60

  values = [
    yamlencode({
      hostGlobal = "http://charles.${local.cluster_domain}"
      CharlesApplications = {
        ui = {
          authUri = "http://${local.keycloak.host}/keycloak"
          image = { tag = local.charlescd.version }
        }
        circleMatcher = {
          redis = {
            host = "redis-master.${kubernetes_namespace.cache.metadata[0].name}.svc.cluster.local"
            password = random_password.redis.result
          }
          image = { tag = local.charlescd.version }
        }
        gate = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_moove"]["database"]
            user = local.database["charlescd_moove"]["user"]
            password = local.database["charlescd_moove"]["password"]
          }
          image = { tag = local.charlescd.version }
        }
        hermes = {
          database = {
            host = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name = local.database["charlescd_hermes"]["database"]
            user = local.database["charlescd_hermes"]["user"]
            password = local.database["charlescd_hermes"]["password"]
          }
          amqp = { url = "amqp://user:${random_password.rabbitmq["password"].result}@rabbitmq.${kubernetes_namespace.queue.metadata[0].name}.svc.cluster.local:5672/" }
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
      postgresql = { enabled = false }
      redis = { enabled = false }
      keycloak = { enabled = false }
      nginx_ingress_controller = { enabled = false }
      rabbitmq = { enabled = false }
    })
  ]

  depends_on = [ helm_release.keycloak ]
}
