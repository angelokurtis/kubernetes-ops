package kubetest_test

import (
	"flag"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
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
