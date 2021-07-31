variable "digitalocean_token" {
  description = "The DigitalOcean API access token used by clients to access the cluster."
}

variable "email" {
  description = "Email address used for ACME registration."
}

variable "private_key" {
  description = "The private key used to decrypt sealed secrets."
}

variable "public_key" {
  description = "The public key used for sealing secrets."
}
