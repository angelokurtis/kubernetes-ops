resource "kubernetes_namespace" "horusec" {
  metadata {
    name = "horusec"
  }
}

resource "kubernetes_namespace" "database" {
  metadata {
    name = "database"
  }
}

resource "kubernetes_namespace" "queue" {
  metadata {
    name = "queue"
  }
}

resource "kubernetes_namespace" "controller" {
  metadata {
    name = "controller"
  }
}
