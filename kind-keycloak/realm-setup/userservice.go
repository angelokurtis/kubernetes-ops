package main

import (
	"context"
	"fmt"
	"github.com/Nerzal/gocloak/v11"
	"github.com/pkg/errors"
	"log"
)

type UserService struct {
	keycloak Keycloak
	token    AccessToken
}

func NewUserService(keycloak Keycloak, token AccessToken) *UserService {
	return &UserService{keycloak: keycloak, token: token}
}

func (svc *UserService) CreateUser(realmID string, user *User) error {
	ctx := context.Background()
	_, err := svc.keycloak.CreateUser(ctx, string(svc.token), realmID, newUser(user))
	if isConflictError(err) {
		return nil
	} else if err != nil {
		return errors.WithStack(err)
	}
	log.Printf("user %q created", user.Username)
	return nil
}

func newUser(user *User) gocloak.User {
	attr := make(map[string][]string, 0)
	for k, v := range user.Attributes {
		attr[k] = []string{fmt.Sprintf("%v", v)}
	}
	return gocloak.User{
		Username:      gocloak.StringP(user.Username),
		Email:         gocloak.StringP(user.Email),
		FirstName:     gocloak.StringP(user.FirstName),
		LastName:      gocloak.StringP(user.LastName),
		Enabled:       gocloak.BoolP(true),
		Totp:          gocloak.BoolP(false),
		EmailVerified: gocloak.BoolP(true),
		Attributes:    &attr,
		Credentials: &[]gocloak.CredentialRepresentation{
			{
				Type:      gocloak.StringP("password"),
				Value:     gocloak.StringP(user.Password),
				Temporary: gocloak.BoolP(false),
			},
		},
	}
}
