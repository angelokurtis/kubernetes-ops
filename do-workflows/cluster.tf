resource "local_file" "kube_config" {
  content = digitalocean_kubernetes_cluster.api_workflow.kube_config[0].raw_config
  filename = "kubeconfig.admin"
}

resource "digitalocean_kubernetes_cluster" "api_workflow" {
  name = "api-workflow"
  region = "nyc1"
  version = data.digitalocean_kubernetes_versions.release_1_20.latest_version

  node_pool {
    name = "default"
    size = "s-1vcpu-2gb"
    node_count = 2
  }
}

resource "digitalocean_project_resources" "api_workflow" {
  project = data.digitalocean_project.api_workflow.id
  resources = [
    "do:kubernetes:${digitalocean_kubernetes_cluster.api_workflow.id}"
  ]
}

data "digitalocean_kubernetes_versions" "release_1_20" {
  version_prefix = "1.20."
}

data "digitalocean_project" "api_workflow" {
  name = "API Workflow"
}
