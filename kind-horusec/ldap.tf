resource "helm_release" "openldap" {
  count = var.ldap_enabled ? 1 : 0

  name = "openldap"
  namespace = kubernetes_namespace.ldap[0].metadata[0].name

  repository = "https://jp-gouin.github.io/helm-openldap"
  chart = "openldap-stack-ha"
  version = "2.1.4"

  values = [
    yamlencode({
      replicaCount = 1,
      ltb-passwd = { ingress = { hosts = [ "ldap-pwd.lvh.me", ] } }
      phpldapadmin = { ingress = { hosts = [ "ldap-adm.lvh.me", ] } }
    })
  ]
}

resource "kubernetes_namespace" "ldap" {
  count = var.ldap_enabled ? 1 : 0

  metadata {
    name = "ldap"
  }
}
