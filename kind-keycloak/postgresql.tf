# TODO: Replace manual installation with either CrunchyData's Postgres Operator (https://github.com/CrunchyData/postgres-operator) or CloudNativePG (https://github.com/cloudnative-pg/cloudnative-pg).

resource "kubernetes_stateful_set_v1" "postgresql_db" {
  metadata {
    name      = "postgresql-db"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  spec {
    service_name = "postgresql-db"
    replicas     = 1

    selector {
      match_labels = { app = "postgresql-db" }
    }

    template {
      metadata {
        labels = { app = "postgresql-db" }
      }

      spec {
        container {
          name  = "postgresql-db"
          image = "postgres:15.14"

          env {
            name  = "POSTGRES_USER"
            value = "keycloak"
          }
          env {
            name  = "POSTGRES_PASSWORD"
            value = random_password.keycloak_db.result
          }
          env {
            name  = "PGDATA"
            value = "/data/pgdata"
          }
          env {
            name  = "POSTGRES_DB"
            value = "keycloak"
          }

          volume_mount {
            mount_path = "/data"
            name       = "cache-volume"
          }
        }

        volume {
          empty_dir {}
          name = "cache-volume"
        }
      }
    }
  }
}

resource "kubernetes_service_v1" "keycloak_postgresql" {
  metadata {
    name      = "keycloak-postgresql"
    namespace = kubernetes_namespace.postgresql.metadata[0].name
  }

  spec {
    selector = {
      app = "postgresql-db"
    }

    type = "ClusterIP"

    port {
      port        = 5432
      target_port = 5432
    }
  }
}

resource "kubernetes_namespace" "postgresql" {
  metadata { name = "postgresql" }
}
