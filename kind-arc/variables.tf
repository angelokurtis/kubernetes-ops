variable "docker_volume" {
  type        = string
  description = "Docker volume for kind Image caching"
  default     = null
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}

variable "github_app_id" {
  type        = string
  description = "The GitHub App ID used for authentication"
}

variable "github_app_installation_id" {
  type        = string
  description = "The installation ID of the GitHub App"
}

variable "github_app_private_key_path" {
  type        = string
  description = "The file path to the private key of the GitHub App used for authentication"
}
