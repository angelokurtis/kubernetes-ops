package main

import (
	"context"
	"log"

	"github.com/Nerzal/gocloak/v11"
	"github.com/pkg/errors"
)

type RealmService struct {
	keycloak Keycloak
	token    AccessToken
}

func NewRealmService(keycloak Keycloak, token AccessToken) *RealmService {
	return &RealmService{keycloak: keycloak, token: token}
}

func (svc *RealmService) CreateRealm(realm *Realm) error {
	ctx := context.Background()

	_, err := svc.keycloak.CreateRealm(ctx, string(svc.token), newRealm(realm.ID))
	if isConflictError(err) {
		return nil
	} else if err != nil {
		return errors.WithStack(err)
	}

	log.Printf("realm %q created", realm.ID)

	return nil
}

func newRealm(id string) gocloak.RealmRepresentation {
	return gocloak.RealmRepresentation{
		ID:      gocloak.StringP(id),
		Realm:   gocloak.StringP(id),
		Enabled: gocloak.BoolP(true),
	}
}
