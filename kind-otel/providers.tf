terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.2.1, < 0.3.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.25.1, < 4.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.12.1, < 3.0.0" }
    kubectl    = { source = "alekc/kubectl", version = ">= 2.0.4, < 3.0.0" }
    null       = { source = "hashicorp/null", version = ">= 3.2.2, < 4.0.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.otel.endpoint

  client_certificate     = kind_cluster.otel.client_certificate
  client_key             = kind_cluster.otel.client_key
  cluster_ca_certificate = kind_cluster.otel.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.otel.endpoint

    client_certificate     = kind_cluster.otel.client_certificate
    client_key             = kind_cluster.otel.client_key
    cluster_ca_certificate = kind_cluster.otel.cluster_ca_certificate
  }
}


provider "kubectl" {
  host = kind_cluster.otel.endpoint

  client_certificate     = kind_cluster.otel.client_certificate
  client_key             = kind_cluster.otel.client_key
  cluster_ca_certificate = kind_cluster.otel.cluster_ca_certificate
  load_config_file       = false
}
