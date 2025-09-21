resource "kubectl_manifest" "keycloak" {
  yaml_body = templatefile("${path.module}/manifests/keycloaks.k8s.keycloak.org/keycloak.yaml", {
    namespace             = kubernetes_namespace.keycloak.metadata[0].name
    host                  = "keycloak.${local.cluster_host}"
    keycloak_admin_secret = kubernetes_secret_v1.keycloak_admin.metadata[0].name
    postgresql_secret    = kubernetes_secret_v1.keycloak_db.metadata[0].name
    postgresql_service   = kubernetes_service_v1.keycloak_postgresql.metadata[0].name
    postgresql_namespace = kubernetes_namespace.postgresql.metadata[0].name
  })

  depends_on = [
    kubectl_manifest.kustomization_keycloak_operator,
    kubernetes_stateful_set_v1.postgresql_db,
  ]
}

resource "random_password" "keycloak_admin" {
  length = 16
}

resource "kubernetes_secret_v1" "keycloak_admin" {
  metadata {
    name      = "keycloak-admin"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    username = "admin"
    password = random_password.keycloak_admin.result
  }
}

resource "random_password" "keycloak_db" {
  length = 16
}

resource "kubernetes_secret_v1" "keycloak_db" {
  metadata {
    name      = "keycloak-db"
    namespace = kubernetes_namespace.keycloak.metadata[0].name
  }
  data = {
    username = "keycloak"
    password = random_password.keycloak_db.result
  }
}

resource "kubernetes_namespace" "keycloak" {
  metadata { name = "keycloak" }
}
