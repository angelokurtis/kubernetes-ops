terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.9"
    }
  }
  required_version = ">= 0.13"
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
