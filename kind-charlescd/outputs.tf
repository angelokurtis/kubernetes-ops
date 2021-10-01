output "charles" {
  sensitive = true
  value     = {
    url         = "http://${local.charlescd.host}/auth/login"
    credentials = {
      user     = "charlesadmin@admin"
      password = random_password.charlescd_user_password.result
    }
  }
}
