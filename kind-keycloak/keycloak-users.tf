data "keycloak_role" "offline_access" {
  realm_id = keycloak_realm.realm.id
  name = "offline_access"
}

data "keycloak_role" "uma_authorization" {
  realm_id = keycloak_realm.realm.id
  name = "uma_authorization"
}

resource "keycloak_role" "admin" {
  realm_id = keycloak_realm.realm.id
  name = "admin"
}

resource "keycloak_role" "user" {
  realm_id = keycloak_realm.realm.id
  name = "user"
}

resource "keycloak_user" "tiago" {
  realm_id = keycloak_realm.realm.id
  username = "tiago"
  enabled = true

  email = "tiago@domain.com"
  email_verified = true
  first_name = "Tiago"
  last_name = "Angelo"

  initial_password {
    value = "123"
    temporary = false
  }
}

resource "keycloak_user_roles" "tiago" {
  realm_id = keycloak_realm.realm.id
  user_id = keycloak_user.tiago.id

  role_ids = [
    keycloak_role.admin.id,
    data.keycloak_role.offline_access.id,
    data.keycloak_role.uma_authorization.id,
  ]
}

resource "keycloak_user" "maria" {
  realm_id = keycloak_realm.realm.id
  username = "maria"
  enabled = true

  email = "maria@domain.com"
  email_verified = true
  first_name = "Maria Cláudia"
  last_name = "Saccomani"

  initial_password {
    value = "321"
    temporary = false
  }
}

resource "keycloak_user_roles" "maria" {
  realm_id = keycloak_realm.realm.id
  user_id = keycloak_user.maria.id

  role_ids = [
    keycloak_role.user.id,
    data.keycloak_role.offline_access.id,
    data.keycloak_role.uma_authorization.id,
  ]
}
