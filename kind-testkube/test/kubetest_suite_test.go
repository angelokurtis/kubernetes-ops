package kubetest_test

import (
	"flag"
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"testing"
)

var host string

func init() {
	flag.StringVar(&host, "host", "testkube-api-server:8088", "Host of the server to test")
}

func TestKubetest(t *testing.T) {
	RegisterFailHandler(Fail)

	RunSpecs(t, "Kubetest Suite")
}
