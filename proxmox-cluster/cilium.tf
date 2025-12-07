resource "helm_release" "cilium" {
  repository = "https://helm.cilium.io"
  chart      = "cilium"
  version    = data.external.cilium_latest_helm_chart.result.version

  name      = "cilium"
  namespace = "kube-system"

  set = [
    { name = "clustermesh.apiserver.image.tag", value = data.external.cilium_latest_release.result.tag_name },
    { name = "hubble.relay.image.tag", value = data.external.cilium_latest_release.result.tag_name },
    { name = "image.tag", value = data.external.cilium_latest_release.result.tag_name },
    { name = "operator.image.tag", value = data.external.cilium_latest_release.result.tag_name },
    { name = "preflight.image.tag", value = data.external.cilium_latest_release.result.tag_name },
    { name = "ipam.mode", value = "kubernetes" },
    { name = "kubeProxyReplacement", value = true },
    { name = "securityContext.capabilities.ciliumAgent", value = "{${join(",", [
      "CHOWN",
      "KILL",
      "NET_ADMIN",
      "NET_RAW",
      "IPC_LOCK",
      "SYS_ADMIN",
      "SYS_RESOURCE",
      "DAC_OVERRIDE",
      "FOWNER",
      "SETGID",
      "SETUID",
    ])}}" },
    { name = "securityContext.capabilities.cleanCiliumState", value = "{${join(",", [
      "NET_ADMIN",
      "SYS_ADMIN",
      "SYS_RESOURCE",
    ])}}" },
    { name = "cgroup.autoMount.enabled", value = false },
    { name = "cgroup.hostRoot", value = "/sys/fs/cgroup" },
    { name = "bpf.masquerade", value = true },
    { name = "k8sServiceHost", value = "localhost" },
    { name = "k8sServicePort", value = 7445 },
  ]
}

data "external" "cilium_latest_helm_chart" {
  program = ["python3", "${path.module}/get_latest_helm_chart_version.py"]

  query = {
    repo   = "https://helm.cilium.io"
    chart  = "cilium"
    semver = ">= 1.0.0, < 2.0.0"
  }
}

data "external" "cilium_latest_release" {
  program = ["python3", "${path.module}/get_latest_github_release_version.py"]

  query = {
    repo   = "cilium/cilium"
    semver = ">= 1.0.0, < 2.0.0"
  }
}
