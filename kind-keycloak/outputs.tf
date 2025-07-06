output "keycloak_access_info" {
  value     = "Access Keycloak at http://${yamldecode(kubernetes_config_map_v1.keycloak_helm_values.data["values.yaml"]).ingress.hostname}/ using username ${yamldecode(kubernetes_config_map_v1.keycloak_helm_values.data["values.yaml"]).auth.adminUser} and password ${kubernetes_secret_v1.keycloak_passwords.data["admin-password"]}"
  sensitive = true
}
