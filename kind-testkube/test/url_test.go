package kubetest_test

import (
	. "github.com/onsi/ginkgo/v2"
	. "github.com/onsi/gomega"
	"net/http"
	"net/url"
)

var _ = Describe("Try TestKube API for a 200", func() {
	It("should return 200", func() {
		resp, requestErr := http.Get((&url.URL{
			Scheme: "http",
			Host:   host,
			Path:   "health",
		}).String())
		Expect(requestErr).To(BeNil())
		Expect(resp.StatusCode).To(Equal(200))
		Expect(resp.Body).To(Equal("OK 👋!"))
	})
})
