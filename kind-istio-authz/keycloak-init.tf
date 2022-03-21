resource "kubernetes_job_v1" "keycloak_init" {
  metadata {
    name      = "keycloak-init"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  spec {
    template {
      metadata {}
      spec {
        service_account_name = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
        init_container {
          name  = "kubectl"
          image = "docker.io/bitnami/kubectl:1.23"
          args  = [
            "wait", "--for=condition=Ready", "helmrelease/keycloak",
            "--timeout", local.default_timeouts,
          ]
        }
        container {
          name              = "keycloak-admin-client"
          image             = "kurtis/keycloak-admin-client:17.0.0"
          image_pull_policy = "IfNotPresent"
          volume_mount {
            mount_path = "/app/script"
            name       = "script"
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
              key  = keys(kubernetes_config_map.keycloak_scripts.data)[0]
              path = "index.js"
            }
          }
        }
        restart_policy = "Never"
      }
    }
  }
  wait_for_completion = true

  timeouts {
    create = local.default_timeouts
    update = local.default_timeouts
  }

  depends_on = [
    kubernetes_role_binding_v1.kubectl_keycloak_helmreleases_reader,
    kubectl_manifest.keycloak_helm_release
  ]
}

resource "kubernetes_config_map" "keycloak_scripts" {
  metadata {
    name      = "keycloak-scripts"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    "keycloak-init.js" = file("${path.cwd}/keycloak-init.js")
  }
}

resource "random_password" "charlescd_client_secret" {
  length  = 16
  special = true
}

resource "random_password" "charlescd_user_password" {
  length  = 16
  special = true
}

resource "kubernetes_secret" "keycloak_init_env_vars" {
  metadata {
    name      = "keycloak-init-env-vars"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    # admin-cli credentials
    BASE_URL      = "http://keycloak.${kubernetes_namespace.keycloak.metadata[0].name}.svc.cluster.local/auth"
    REALM_NAME    = "master"
    CLIENT_ID     = "admin-cli"
    USERNAME      = "admin"
    PASSWORD      = random_password.keycloak_admin.result
    GRANT_TYPE    = "password"
    # new private client credentials
    CLIENT_SECRET = random_password.charlescd_client_secret.result
  }
}

resource "kubernetes_role_v1" "keycloak_helmreleases_reader" {
  metadata {
    name      = "keycloak-helmreleases-reader"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  rule {
    api_groups = ["helm.toolkit.fluxcd.io"]
    resources  = ["helmreleases"]
    verbs      = ["get", "list", "watch"]
  }
}

resource "kubernetes_service_account_v1" "keycloak_kubectl" {
  metadata {
    name      = "kubectl"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}

resource "kubernetes_role_binding_v1" "kubectl_keycloak_helmreleases_reader" {
  metadata {
    name      = "kubectl-keycloak-helmreleases-reader"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "Role"
    name      = kubernetes_role_v1.keycloak_helmreleases_reader.metadata[0].name
  }
  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account_v1.keycloak_kubectl.metadata[0].name
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
}
