package kubetest_test

import (
	"fmt"
	"net/http"
)

var _ = Describe("Try Google for a 200", func() {
	It("should return 200", func() {
		resp, requestErr := http.Get(fmt.Sprintf("https://%s", baseURL))
		Expect(requestErr).To(BeNil())
		Expect(resp.StatusCode).To(Equal(200))
	})
})
