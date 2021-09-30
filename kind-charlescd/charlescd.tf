locals {
  charlescd = {
    version = "1.0.1"
    host    = "charles.${local.cluster_domain}"
  }
}

resource "helm_release" "charlescd" {
  name      = "charlescd"
  namespace = kubernetes_namespace.continuous_deployment.metadata[0].name

  repository = "https://charts.kurtis.dev.br/"
  chart      = "charlescd"
  version    = "0.7.0"

  timeout = 10*60

  values = [
    yamlencode({
      hostGlobal               = "http://${local.charlescd.host}"
      CharlesApplications      = {
        ui            = {
          allowedOriginHost = "http://${local.charlescd.host}"
          apiHost           = "http://${local.charlescd.host}"
          authUri           = "http://${local.keycloak.host}"
          idmRedirectHost   = "http://${local.charlescd.host}"
          image             = { tag = local.charlescd.version }
          pullPolicy        = "IfNotPresent"
          resources         = { limits = null }
          healthCheck       = { initialDelay = 5 }
        }
        circleMatcher = {
          allowedOriginHost = "http://${local.charlescd.host}"
          redis             = {
            host     = "redis-master.${kubernetes_namespace.cache.metadata[0].name}.svc.cluster.local"
            password = random_password.redis.result
          }
          image             = { tag = local.charlescd.version }
          pullPolicy        = "IfNotPresent"
          resources         = { limits = null }
          healthCheck       = { initialDelay = 5 }
        }
        gate          = {
          database    = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_moove"]["database"]
            user     = local.database["charlescd_moove"]["user"]
            password = local.database["charlescd_moove"]["password"]
          }
          image       = { tag = local.charlescd.version }
          pullPolicy  = "IfNotPresent"
          resources   = { limits = null }
          healthCheck = { initialDelay = 5 }
        }
        hermes        = {
          database    = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_hermes"]["database"]
            user     = local.database["charlescd_hermes"]["user"]
            password = local.database["charlescd_hermes"]["password"]
          }
          amqp        = {
            url = "amqp://user:${random_password.rabbitmq["password"].result}@rabbitmq.${kubernetes_namespace.queue.metadata[0].name}.svc.cluster.local:5672/"
          }
          image       = { tag = local.charlescd.version }
          pullPolicy  = "IfNotPresent"
          resources   = { limits = null }
          healthCheck = { initialDelay = 5 }
        }
        butler        = {
          database    = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_butler"]["database"]
            user     = local.database["charlescd_butler"]["user"]
            password = local.database["charlescd_butler"]["password"]
          }
          image       = { tag = local.charlescd.version }
          pullPolicy  = "IfNotPresent"
          resources   = { limits = null }
          healthCheck = { initialDelay = 5 }
        }
        compass       = {
          database    = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_compass"]["database"]
            user     = local.database["charlescd_compass"]["user"]
            password = local.database["charlescd_compass"]["password"]
          }
          moove       = {
            database = {
              host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
              name     = local.database["charlescd_moove"]["database"]
              user     = local.database["charlescd_moove"]["user"]
              password = local.database["charlescd_moove"]["password"]
            }
          }
          image       = { tag = local.charlescd.version }
          pullPolicy  = "IfNotPresent"
          resources   = { limits = null }
          healthCheck = { initialDelay = 5 }
        }
        moove         = {
          allowedOriginHost = "http://${local.charlescd.host}"
          image             = { tag = local.charlescd.version }
          pullPolicy        = "IfNotPresent"
          resources         = { limits = null }
          healthCheck       = { initialDelay = 5 }
          database          = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_moove"]["database"]
            user     = local.database["charlescd_moove"]["user"]
            password = local.database["charlescd_moove"]["password"]
          }
        }
        villager      = {
          database    = {
            host     = "postgresql.${kubernetes_namespace.database.metadata[0].name}.svc.cluster.local"
            name     = local.database["charlescd_villager"]["database"]
            user     = local.database["charlescd_villager"]["user"]
            password = local.database["charlescd_villager"]["password"]
          }
          image       = { tag = local.charlescd.version }
          pullPolicy  = "IfNotPresent"
          resources   = { limits = null }
          healthCheck = { initialDelay = 5 }
        }
      }
      ingress                  = { enabled = false }
      postgresql               = { enabled = false }
      redis                    = { enabled = false }
      keycloak                 = { enabled = false }
      nginx_ingress_controller = { enabled = false }
      rabbitmq                 = { enabled = false }
      envoy                    = {
        idm = {
          endpoint = local.keycloak.host
          path     = "/auth/realms/charlescd/protocol/openid-connect/userinfo"
        }
      }
    })
  ]

  depends_on = [helm_release.keycloak]
}

# TODO: this is a workaround as the current version of Charles Helm Chart is not able to set the `pathType`
resource "kustomization_resource" "charlescd_ingress" {
  manifest = jsonencode({
    "apiVersion" = "networking.k8s.io/v1"
    "kind"       = "Ingress"
    "metadata"   = {
      "name"        = "charlescd-ingress"
      "namespace"   = kubernetes_namespace.continuous_deployment.metadata[0].name
      "annotations" = { "kubernetes.io/ingress.class" = "istio" }
    }
    "spec"       = {
      "rules" = [
        {
          "host" = local.charlescd.host
          "http" = {
            "paths" = [
              {
                "backend"  = { "service" = { "name" = "envoy-proxy", "port" = { "number" = 80 } } },
                "path"     = "/",
                "pathType" = "Prefix"
              }
            ]
          }
        }
      ]
    }
  })

  depends_on = [helm_release.charlescd]
}
