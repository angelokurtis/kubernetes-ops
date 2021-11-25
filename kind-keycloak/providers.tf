terraform {
  required_providers {
    kind       = { source = "kyma-incubator/kind", version = ">= 0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.3" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.5" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "helm" {
  kubernetes {
    config_path = kind_cluster.keycloak.kubeconfig_path
  }
}

provider "kubernetes" {
  config_path = kind_cluster.keycloak.kubeconfig_path
}
