variable "enable_local_registry" {
  type = bool
  description = "If set to true, it will create a local docker registry"
  default = false
}

variable "registry_name" {
  type = string
  default = "kind-registry"
}

variable "registry_port" {
  type = number
  default = 5000
}

variable "ingress_domain" {
  type = string
  default = "istio.local"
}