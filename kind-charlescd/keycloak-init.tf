resource "kubernetes_job" "keycloak_init" {
  metadata {
    name = "keycloak-init"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        container {
          name = "keycloak-admin-client"
          image = "kurtis/keycloak-admin-client:${local.keycloak.version}"
          image_pull_policy = "Always"
          volume_mount {
            mount_path = "/app/script"
            name = "script"
          }
          env_from {
            secret_ref {
              name = kubernetes_secret.keycloak_init_env_vars.metadata[0].name
            }
          }
        }
        volume {
          name = "script"
          config_map {
            name = kubernetes_config_map.keycloak_scripts.metadata[0].name
            items {
              key = keys(kubernetes_config_map.keycloak_scripts.data)[0]
              path = "index.js"
            }
          }
        }
        restart_policy = "Never"
      }
    }
    backoff_limit = 4
  }
  wait_for_completion = true

  depends_on = [
    helm_release.keycloak]
}

resource "kubernetes_config_map" "keycloak_scripts" {
  metadata {
    name = "keycloak-scripts"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    "keycloak-init.js" = file("${path.cwd}/keycloak-init.js")
  }
}

resource "random_password" "api_client_secret" {
  length = 16
  special = true
}

resource "kubernetes_secret" "keycloak_init_env_vars" {
  metadata {
    name = "keycloak-init-env-vars"
    namespace = kubernetes_namespace.iam.metadata[0].name
  }
  data = {
    BASE_URL = "http://keycloak.${kubernetes_namespace.iam.metadata[0].name}.svc.cluster.local/auth"
    REALM_NAME = "master"
    CLIENT_ID = "admin-cli"
    USERNAME = "admin"
    PASSWORD = local.keycloak.admin.password
    GRANT_TYPE = "password"
  }
}
