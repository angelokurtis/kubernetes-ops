terraform {
  required_providers {
    digitalocean = {
      source = "digitalocean/digitalocean"
      version = "2.10.1"
    }
  }
}

provider "digitalocean" {
  token = var.digitalocean_token
}

