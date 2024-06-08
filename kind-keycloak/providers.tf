terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.5.1, < 1.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.30.0, < 4.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.13.2, < 3.0.0" }
    kubectl    = { source = "alekc/kubectl", version = ">= 2.0.4, < 3.0.0" }
    null       = { source = "hashicorp/null", version = ">= 3.2.2, < 4.0.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.keycloak.endpoint

  client_certificate     = kind_cluster.keycloak.client_certificate
  client_key             = kind_cluster.keycloak.client_key
  cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.keycloak.endpoint

    client_certificate     = kind_cluster.keycloak.client_certificate
    client_key             = kind_cluster.keycloak.client_key
    cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
  }
}


provider "kubectl" {
  host = kind_cluster.keycloak.endpoint

  client_certificate     = kind_cluster.keycloak.client_certificate
  client_key             = kind_cluster.keycloak.client_key
  cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
  load_config_file       = false
}
