package main

import (
	"github.com/kelseyhightower/envconfig"
	"github.com/pkg/errors"
)

type KeycloakConfig struct {
	BaseURL       string `required:"true" envconfig:"BASE_URL"`
	RealmName     string `required:"true" envconfig:"REALM_NAME"`
	Username      string `required:"true" envconfig:"USERNAME"`
	Password      string `required:"true" envconfig:"PASSWORD"`
	RealmJSONPath string `required:"true" envconfig:"REALM_JSON_PATH"`
}

// NewKeycloakConfig read Keycloak configs from env vars
func NewKeycloakConfig() (*KeycloakConfig, error) {
	k := new(KeycloakConfig)

	err := envconfig.Process("KEYCLOAK", k)
	if err != nil {
		return nil, errors.WithStack(err)
	}

	return k, nil
}
