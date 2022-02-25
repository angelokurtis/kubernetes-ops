output "charles" {
  value = {
    url         = "http://${local.charlescd.host}/auth/login"
    credentials = {
      user     = "charlesadmin@admin"
      password = nonsensitive(random_password.charlescd_user_password.result)
    }
  }
}

output "keycloak" {
  value = {
    url         = "http://${local.keycloak.host}/auth/admin/"
    credentials = {
      user     = "admin"
      password = nonsensitive(random_password.keycloak_admin.result)
    }
  }
}
