variable "mongodb_user" {
  type = string
  default = "tiago.angelo"
}

variable "mongodb_pass" {
  type = string
  default = "m0n90d8_p455"
}

variable "horusec_project_path" {
  type = string
  default = "/home/tiagoangelo/wrkspc/github.com/ZupIT/horusec"
}

variable account_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Accounts service"
  default = true
}

variable analytic_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Analytics service"
  default = true
}

variable api_enabled {
  type = bool
  description = "If set to true, it will install the Horusec API service"
  default = true
}

variable auth_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Auth service"
  default = true
}

variable manager_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Manager service"
  default = true
}

variable messages_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Messages service"
  default = true
}

variable webhook_enabled {
  type = bool
  description = "If set to true, it will install the Horusec Webhook service"
  default = true
}