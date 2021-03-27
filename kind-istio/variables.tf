variable "addons" {
  description = "Install the Istio's Telemetry Addons"
  type = object({
    kiali = object({ enabled = bool })
    grafana = object({ enabled = bool })
    tracing = object({ enabled = bool })
    prometheus = object({ enabled = bool })
  })
  default = {
    kiali = { enabled = true }
    grafana = { enabled = true }
    tracing = { enabled = true }
    prometheus = { enabled = true }
  }
}
