package main

import (
	"github.com/Nerzal/gocloak/v11"
)

type Keycloak gocloak.GoCloak

func NewKeycloak(config *KeycloakConfig) Keycloak {
	return gocloak.NewClient(config.BaseURL)
}
