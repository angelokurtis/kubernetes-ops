variable "horusec_namespace" {
  type = string
  description = "The namespace where the solution will be installed"
  default = "security"
}

variable "ldap_enabled" {
  type = bool
  description = "If set to true, it will deploy OpenLDAP"
  default = false
}

variable "jaeger_enabled" {
  type = bool
  description = "If set to true, it will deploy Jaeger"
  default = false
}

variable "keycloak_enabled" {
  type = bool
  description = "If set to true, it will deploy Keycloak"
  default = false
}

variable "argo_enabled" {
  type = bool
  description = "If set to true, it will deploy ArgoCD"
  default = false
}

variable "horusec_operator_version" {
  type = string
  description = "The version of Horusec Kubernetes Operator"
  default = "v2.1.0"
}

variable "horusec_admin_version" {
  type = string
  description = "The version of Horusec Administrator"
  default = "v2.0.0"
}

variable "argo_namespace" {
  default = "continuous-delivery"
}
