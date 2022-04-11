package main

import (
	"context"
	"github.com/pkg/errors"
)

type AccessToken string

func NewAccessToken(keycloak Keycloak, config *KeycloakConfig) (AccessToken, error) {
	token, err := keycloak.LoginAdmin(context.Background(), config.Username, config.Password, config.RealmName)
	if err != nil {
		return "", errors.WithStack(err)
	}
	return AccessToken(token.AccessToken), nil
}
