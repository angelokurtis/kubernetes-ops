terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.10.1"
    }
    kubernetes = {
      source = "hashicorp/kubernetes"
      version = "2.3.2"
    }
    helm = {
      source = "hashicorp/helm"
      version = "2.2.0"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

provider "kubernetes" {
  host = digitalocean_kubernetes_cluster.api_workflow.endpoint
  token = digitalocean_kubernetes_cluster.api_workflow.kube_config[0].token
  cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.api_workflow.kube_config[0].cluster_ca_certificate)
}

provider "helm" {
  kubernetes {
    host = digitalocean_kubernetes_cluster.api_workflow.endpoint
    token = digitalocean_kubernetes_cluster.api_workflow.kube_config[0].token
    cluster_ca_certificate = base64decode(digitalocean_kubernetes_cluster.api_workflow.kube_config[0].cluster_ca_certificate)
  }
}
