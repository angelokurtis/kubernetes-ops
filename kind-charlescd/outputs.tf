output "charles" {
  value = {
    url         = "http://${local.charlescd.host}/auth/login"
    credentials = {
      user     = "charlesadmin@admin"
      password = nonsensitive(random_password.charlescd_user_password.result)
    }
  }
}
