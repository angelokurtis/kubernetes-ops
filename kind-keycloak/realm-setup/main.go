package main

import (
	"log"
)

func main() {
	// initialize
	keycloakConfig, err := NewKeycloakConfig()
	if err != nil {
		log.Fatalf("%+v", err)
	}
	realm, err := NewRealm(keycloakConfig)
	if err != nil {
		log.Fatalf("%+v", err)
	}
	keycloak := NewKeycloak(keycloakConfig)
	accessToken, err := NewAccessToken(keycloak, keycloakConfig)
	if err != nil {
		log.Fatalf("%+v", err)
	}
	userService := NewUserService(keycloak, accessToken)
	realmService := NewRealmService(keycloak, accessToken)
	clientService := NewClientService(keycloak, accessToken)

	// create realm if not exists
	if err = realmService.CreateRealm(realm); err != nil {
		log.Fatalf("%+v", err)
	}

	// create private clients if not exists
	for _, client := range realm.Clients.Private {
		if err = clientService.CreatePrivateClient(realm.ID, client); err != nil {
			log.Fatalf("%+v", err)
		}
	}

	// create public clients if not exists
	for _, client := range realm.Clients.Public {
		if err = clientService.CreatePublicClient(realm.ID, client); err != nil {
			log.Fatalf("%+v", err)
		}
	}

	// create users if not exists
	for _, user := range realm.Users {
		if err = userService.CreateUser(realm.ID, user); err != nil {
			log.Fatalf("%+v", err)
		}
	}

	// map users extra attributes to client
	for _, client := range realm.Clients.Public {
		if err = clientService.UpdateClientProtocolMapper(realm.ID, client.ID, realm.Users); err != nil {
			log.Fatalf("%+v", err)
		}
	}
}
