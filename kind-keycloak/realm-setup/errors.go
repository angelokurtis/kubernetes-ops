package main

import (
	"github.com/Nerzal/gocloak/v11"
	"github.com/pkg/errors"
)

func isConflictError(err error) bool {
	if err == nil {
		return false
	}
	var apiErr *gocloak.APIError
	if errors.As(err, &apiErr) {
		return apiErr.Code == 409
	}
	return false
}
