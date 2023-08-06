variable "image_caching" {
  type        = bool
  description = "Use Docker volume for kind Image caching"
  default     = false
}

variable "load_balancer_address" {
  type        = string
  description = "The IP addresses associated with a load balancer"
  default     = "127.0.0.1"
}
