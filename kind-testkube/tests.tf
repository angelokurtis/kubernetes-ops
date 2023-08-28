resource "kubectl_manifest" "test_ginkgo_testkube_api_test" {
  yaml_body = <<-YAML
    apiVersion: tests.testkube.io/v3
    kind: Test
    metadata:
      name: ginkgo-testkube-api-test
      namespace: ${kubernetes_namespace.testkube.metadata[0].name}
      labels:
        executor: ginkgo-executor
        test-type: ginkgo-test
    spec:
      type: ginkgo/test
      content:
        type: git
        repository:
          uri: https://github.com/angelokurtis/kubernetes-ops.git
          branch: master
          path: kind-testkube/test
  YAML

  depends_on = [kubernetes_job_v1.wait_testkube_crd]
}
