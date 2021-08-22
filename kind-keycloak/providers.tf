terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.7"
    }
    keycloak = {
      source = "mrparkers/keycloak"
      version = "3.3.0"
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

provider "keycloak" {
  client_id = "admin-cli"
  username = local.keycloak.admin.user
  password = local.keycloak.admin.password
  url = "http://${local.keycloak.host}"
}

