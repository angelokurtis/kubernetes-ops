variable "docker_volume" {
  type        = string
  description = "Docker volume for kind Image caching"
  nullable    = false
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}
