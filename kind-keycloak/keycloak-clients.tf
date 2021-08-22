resource "keycloak_realm" "realm" {
  realm = "Kurtis"
}

resource "keycloak_openid_client" "demo_frontend" {
  realm_id = keycloak_realm.realm.id
  client_id = "demo-frontend"

  access_type = "PUBLIC"
  pkce_code_challenge_method = "S256"

  standard_flow_enabled = true
  direct_access_grants_enabled = true
  valid_redirect_uris = [
    "http://0.0.0.0:8000/*",
    "http://127.0.0.1:8000/*",
    "http://localhost:8000/*",
  ]
  web_origins = [
    "http://0.0.0.0:8000",
    "http://127.0.0.1:8000",
    "http://localhost:8000",
  ]
}

resource "keycloak_openid_client" "demo_backend" {
  realm_id = keycloak_realm.realm.id
  client_id = "demo-backend"

  access_type = "CONFIDENTIAL"
}
