variable "docker_volume" {
  type        = string
  description = "Docker volume for kind Image caching"
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}

variable "fluxcd_namespace" {
  default = "fluxcd"
}

variable "traefik_namespace" {
  default = "traefik"
}

variable "prometheus_namespace" {
  default = "prometheus"
}
