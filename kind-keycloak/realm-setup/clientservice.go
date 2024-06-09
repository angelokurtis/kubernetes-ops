package main

import (
	"context"
	"log"
	"net/url"

	"github.com/Nerzal/gocloak/v11"
	"github.com/pkg/errors"
)

type ClientService struct {
	keycloak Keycloak
	token    AccessToken
}

func NewClientService(keycloak Keycloak, token AccessToken) *ClientService {
	return &ClientService{keycloak: keycloak, token: token}
}

func (svc *ClientService) CreatePrivateClient(realmID string, client *PrivateClient) error {
	ctx := context.Background()

	_, err := svc.keycloak.CreateClient(ctx, string(svc.token), realmID, newPrivateClient(client.ID, client.Secret))
	if isConflictError(err) {
		return nil
	} else if err != nil {
		return errors.WithStack(err)
	}

	log.Printf("private client %q created", client.ID)

	return nil
}

func (svc *ClientService) CreatePublicClient(realmID string, client *PublicClient) error {
	ctx := context.Background()

	_, err := svc.keycloak.CreateClient(ctx, string(svc.token), realmID, newPublicClient(client.ID, client.WebOrigins...))
	if isConflictError(err) {
		return nil
	} else if err != nil {
		return errors.WithStack(err)
	}

	log.Printf("public client %q created", client.ID)

	return nil
}

func (svc *ClientService) UpdateClientProtocolMapper(realmID, clientID string, users []*User) error {
	attrs := make(map[string]interface{}, 0)

	for _, user := range users {
		for k, v := range user.Attributes {
			attrs[k] = v
		}
	}
	var mappers []gocloak.ProtocolMapperRepresentation

	for k, v := range attrs {
		switch v.(type) {
		case float64:
			mappers = append(mappers, newProtocolMapper(k, "long"))
		default:
			mappers = append(mappers, newProtocolMapper(k, "String"))
		}
	}

	ctx := context.Background()

	clients, err := svc.keycloak.GetClients(ctx, string(svc.token), realmID, gocloak.GetClientsParams{
		ClientID: gocloak.StringP(clientID),
	})
	if err != nil {
		return errors.WithStack(err)
	}

	for _, client := range clients {
		client.ProtocolMappers = &mappers

		err = svc.keycloak.UpdateClient(ctx, string(svc.token), realmID, *client)
		if err != nil {
			return errors.WithStack(err)
		}
	}

	return nil
}

func newPublicClient(id string, webOrigins ...string) gocloak.Client {
	var redirectURIs []string

	for _, webOrigin := range webOrigins {
		u, err := url.Parse(webOrigin)
		if err != nil {
			log.Fatalf("%+v", errors.WithStack(err))
		}

		u.Path = "*"
		redirectURIs = append(redirectURIs, u.String())
	}

	return gocloak.Client{
		ClientID:                  gocloak.StringP(id),
		PublicClient:              gocloak.BoolP(true),
		DirectAccessGrantsEnabled: gocloak.BoolP(true),
		RedirectURIs:              &redirectURIs,
		WebOrigins:                &webOrigins,
		Attributes:                &map[string]string{"pkce.code.challenge.method": "S256"},
		ProtocolMappers: &[]gocloak.ProtocolMapperRepresentation{
			newProtocolMapper("age", "int"),
		},
	}
}

func newPrivateClient(id, secret string) gocloak.Client {
	return gocloak.Client{
		ClientID:            gocloak.StringP(id),
		Secret:              gocloak.StringP(secret),
		StandardFlowEnabled: gocloak.BoolP(false),
	}
}

func newProtocolMapper(name, jsonType string) gocloak.ProtocolMapperRepresentation {
	return gocloak.ProtocolMapperRepresentation{
		Config: &map[string]string{
			"access.token.claim":   "true",
			"claim.name":           name,
			"id.token.claim":       "true",
			"jsonType.label":       jsonType,
			"user.attribute":       name,
			"userinfo.token.claim": "true",
		},
		Name:           gocloak.StringP(name),
		Protocol:       gocloak.StringP("openid-connect"),
		ProtocolMapper: gocloak.StringP("oidc-usermodel-attribute-mapper"),
	}
}
