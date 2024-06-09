package main

import (
	"encoding/json"
	"io/ioutil"
	"os"

	"github.com/pkg/errors"
)

func UnmarshalRealm(data []byte) (*Realm, error) {
	r := new(Realm)

	err := json.Unmarshal(data, r)
	if err != nil {
		return nil, errors.WithStack(err)
	}

	return r, nil
}

func (r *Realm) Marshal() ([]byte, error) {
	return json.Marshal(r)
}

type Realm struct {
	Clients Clients `json:"clients"`
	ID      string  `json:"id"`
	Users   []*User `json:"users"`
}

func NewRealm(config *KeycloakConfig) (*Realm, error) {
	file, err := os.Open(config.RealmJSONPath)
	if err != nil {
		return nil, errors.WithStack(err)
	}
	defer file.Close()

	data, err := ioutil.ReadAll(file)
	if err != nil {
		return nil, errors.WithStack(err)
	}

	return UnmarshalRealm(data)
}

type Clients struct {
	Private []*PrivateClient `json:"private"`
	Public  []*PublicClient  `json:"public"`
}

type PrivateClient struct {
	ID     string `json:"id"`
	Secret string `json:"secret"`
}

type PublicClient struct {
	ID         string   `json:"id"`
	WebOrigins []string `json:"web_origins"`
}

type User struct {
	Email      string                 `json:"email"`
	FirstName  string                 `json:"first_name"`
	LastName   string                 `json:"last_name"`
	Password   string                 `json:"password"`
	Username   string                 `json:"username"`
	Attributes map[string]interface{} `json:"attributes,omitempty"`
}
