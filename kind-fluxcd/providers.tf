terraform {
  required_providers {
    aws        = { source = "hashicorp/aws", version = ">= 4.18.0, < 4.19.0" }
    docker     = { source = "kreuzwerker/docker", version = ">= 2.16.0, < 2.17.0" }
    kind       = { source = "tehcyx/kind", version = ">= 0.0.12, < 0.1.0" }
    flux       = { source = "fluxcd/flux", version = ">= 0.15.1, < 0.16.0" }
    kubernetes = { source = "hashicorp/kubernetes", version = ">= 2.11.0, < 2.12.0" }
    kubectl    = { source = "gavinbunney/kubectl", version = ">= 1.14.0, < 1.15.0" }
  }
  required_version = ">= 1.0"
}

provider "aws" {
  access_key                  = "m0(k_4((355_k3y"
  region                      = "us-east-1"
  s3_use_path_style           = true
  secret_key                  = "m0(k_53(r37_k3y"
  skip_credentials_validation = true
  skip_metadata_api_check     = true
  skip_requesting_account_id  = true

  endpoints {
    apigateway     = "http://localhost:4566"
    cloudformation = "http://localhost:4566"
    cloudwatch     = "http://localhost:4566"
    dynamodb       = "http://localhost:4566"
    es             = "http://localhost:4566"
    firehose       = "http://localhost:4566"
    iam            = "http://localhost:4566"
    kinesis        = "http://localhost:4566"
    lambda         = "http://localhost:4566"
    route53        = "http://localhost:4566"
    redshift       = "http://localhost:4566"
    s3             = "http://localhost:4566"
    secretsmanager = "http://localhost:4566"
    ses            = "http://localhost:4566"
    sns            = "http://localhost:4566"
    sqs            = "http://localhost:4566"
    ssm            = "http://localhost:4566"
    stepfunctions  = "http://localhost:4566"
    sts            = "http://localhost:4566"
  }
}

provider "docker" {}

provider "kind" {}

provider "flux" {}

provider "kubernetes" {
  host = kind_cluster.flux.endpoint

  client_certificate     = kind_cluster.flux.client_certificate
  client_key             = kind_cluster.flux.client_key
  cluster_ca_certificate = kind_cluster.flux.cluster_ca_certificate
}

provider "kubectl" {
  host = kind_cluster.flux.endpoint

  client_certificate     = kind_cluster.flux.client_certificate
  client_key             = kind_cluster.flux.client_key
  cluster_ca_certificate = kind_cluster.flux.cluster_ca_certificate
  load_config_file       = false
}
