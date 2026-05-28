terraform {
  required_providers {
    helm       = { source = "hashicorp/helm", version = "~> 3.1" }
    kind       = { source = "tehcyx/kind", version = "~> 0.11" }
    kubectl    = { source = "alekc/kubectl", version = "~> 2.4" }
    kubernetes = { source = "hashicorp/kubernetes", version = "~> 3.1" }
    null       = { source = "hashicorp/null", version = "~> 3.3" }
    random     = { source = "hashicorp/random", version = "~> 3.9" }
  }
  required_version = ">= 1.9"
}

provider "helm" {
  kubernetes = {
    host = kind_cluster.keycloak.endpoint

    client_certificate     = kind_cluster.keycloak.client_certificate
    client_key             = kind_cluster.keycloak.client_key
    cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.keycloak.endpoint

  client_certificate     = kind_cluster.keycloak.client_certificate
  client_key             = kind_cluster.keycloak.client_key
  cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.keycloak.endpoint

  client_certificate     = kind_cluster.keycloak.client_certificate
  client_key             = kind_cluster.keycloak.client_key
  cluster_ca_certificate = kind_cluster.keycloak.cluster_ca_certificate
}

provider "null" {
}

provider "random" {
}
