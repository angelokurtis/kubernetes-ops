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
  type        = string
  description = "The namespace for FluxCD, a tool for GitOps, which automates Kubernetes deployments"
  default     = "fluxcd"
}

variable "prometheus_namespace" {
  type        = string
  description = "The namespace for Prometheus, a monitoring and alerting toolkit for Kubernetes"
  default     = "prometheus"
}

variable "slack_webhook_url" {
  type        = string
  description = "The URL of the Slack webhook for sending alerts and notifications"
  sensitive   = true
  nullable    = false
}
