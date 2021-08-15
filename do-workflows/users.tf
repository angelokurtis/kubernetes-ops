locals {
  users = [
    "tiago",
    "claudio"
  ]
}

resource "local_file" "tiago_kube_config" {
  for_each = toset(local.users)

  content = templatefile("${path.module}/templates/kubeconfig.tpl", {
    cluster = {
      name = "do-${digitalocean_kubernetes_cluster.api_workflow.region}-${digitalocean_kubernetes_cluster.api_workflow.name}"
      certificate_authority = digitalocean_kubernetes_cluster.api_workflow.kube_config[0].cluster_ca_certificate
      endpoint = digitalocean_kubernetes_cluster.api_workflow.endpoint
    }
    user = {
      name = each.key
      crt = base64encode(kubernetes_certificate_signing_request.users[each.key].certificate)
      key = base64encode(tls_private_key.users[each.key].private_key_pem)
    }
  })
  filename = "kubeconfig.${each.key}"
}

resource "tls_private_key" "users" {
  for_each = toset(local.users)

  algorithm = "RSA"
  rsa_bits = "4096"
}

resource "tls_cert_request" "users" {
  for_each = toset(local.users)

  key_algorithm = tls_private_key.users[each.key].algorithm
  private_key_pem = tls_private_key.users[each.key].private_key_pem

  subject {
    common_name = each.key
    organization = "developers"
  }
}

resource "kubernetes_certificate_signing_request" "users" {
  for_each = toset(local.users)

  metadata {
    name = "${each.key}-authentication"
  }
  spec {
    request = tls_cert_request.users[each.key].cert_request_pem
    usages = [
      "digital signature",
      "key encipherment",
      "server auth",
      "client auth"
    ]
  }
  auto_approve = true
}
