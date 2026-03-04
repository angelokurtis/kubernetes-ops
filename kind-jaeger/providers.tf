terraform {
  required_providers {
    external      = { source = "hashicorp/external",   version = "~> 2.3" }
    helm          = { source = "hashicorp/helm",       version = "~> 3.1" }
    kind          = { source = "tehcyx/kind",          version = "~> 0.11" }
    kubectl       = { source = "alekc/kubectl",        version = "~> 2.1" }
    kubernetes    = { source = "hashicorp/kubernetes", version = "~> 3.0" }
    kustomization = { source = "kbst/kustomization",   version = "~> 0.9" }
    null          = { source = "hashicorp/null",       version = "~> 3.2" }
  }
  required_version = ">= 1.9"
}

provider "helm" {
  kubernetes = {
    host = kind_cluster.jaeger.endpoint

    client_certificate     = kind_cluster.jaeger.client_certificate
    client_key             = kind_cluster.jaeger.client_key
    cluster_ca_certificate = kind_cluster.jaeger.cluster_ca_certificate
  }
}

provider "kind" {}

provider "kubectl" {
  host = kind_cluster.jaeger.endpoint

  client_certificate     = kind_cluster.jaeger.client_certificate
  client_key             = kind_cluster.jaeger.client_key
  cluster_ca_certificate = kind_cluster.jaeger.cluster_ca_certificate
  load_config_file       = false
}

provider "kubernetes" {
  host = kind_cluster.jaeger.endpoint

  client_certificate     = kind_cluster.jaeger.client_certificate
  client_key             = kind_cluster.jaeger.client_key
  cluster_ca_certificate = kind_cluster.jaeger.cluster_ca_certificate
}

provider "kustomization" {
  kubeconfig_raw = kind_cluster.jaeger.kubeconfig
}

provider "null" {
}
