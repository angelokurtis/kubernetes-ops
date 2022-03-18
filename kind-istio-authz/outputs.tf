output "keycloak" {
  value = {
    username = "admin"
    password = nonsensitive(random_password.keycloak_admin.result)
  }
}