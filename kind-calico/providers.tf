terraform {
  required_providers {
    kind       = { source = "tehcyx/kind", version = ">= 0.6.0, < 1.0.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.32.0, < 4.0.0" }
    helm       = { source = "hashicorp/helm", version = ">= 2.15.0, < 3.0.0" }
    kubectl    = { source = "alekc/kubectl", version = ">= 2.0.4, < 3.0.0" }
    null       = { source = "hashicorp/null", version = ">= 3.2.2, < 4.0.0" }
  }
  required_version = ">= 1.0"
}

provider "kind" {}

provider "kubernetes" {
  host = kind_cluster.ktstst.endpoint

  client_certificate     = kind_cluster.ktstst.client_certificate
  client_key             = kind_cluster.ktstst.client_key
  cluster_ca_certificate = kind_cluster.ktstst.cluster_ca_certificate
}

provider "helm" {
  kubernetes {
    host = kind_cluster.ktstst.endpoint

    client_certificate     = kind_cluster.ktstst.client_certificate
    client_key             = kind_cluster.ktstst.client_key
    cluster_ca_certificate = kind_cluster.ktstst.cluster_ca_certificate
  }
}


provider "kubectl" {
  host = kind_cluster.ktstst.endpoint

  client_certificate     = kind_cluster.ktstst.client_certificate
  client_key             = kind_cluster.ktstst.client_key
  cluster_ca_certificate = kind_cluster.ktstst.cluster_ca_certificate
  load_config_file       = false
}
