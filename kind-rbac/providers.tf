terraform {
  required_providers {
    kind = {
      source = "kyma-incubator/kind"
      version = "0.0.9"
    }
    kustomization = {
      source = "kbst/kustomization"
      version = "0.5.0"
    }
  }
  required_version = ">= 0.14"
}

provider "helm" {
  kubernetes { config_path = kind_cluster.rbac.kubeconfig_path }
}

provider "kind" {}

provider "kubernetes" { config_path = kind_cluster.rbac.kubeconfig_path }

provider "kustomization" { kubeconfig_path = kind_cluster.rbac.kubeconfig_path }
