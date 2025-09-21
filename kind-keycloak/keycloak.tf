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
