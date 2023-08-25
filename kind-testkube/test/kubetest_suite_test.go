package kubetest_test

import (
	"flag"
	"testing"
)

var baseURL string

func init() {
	flag.StringVar(&baseURL, "base-url", "", "Url of the server to test")
}

func TestKubetest(t *testing.T) {
	RegisterFailHandler(Fail)

	if baseURL == "" {
		baseURL = "google.com"
	}

	RunSpecs(t, "Kubetest Suite")
}
