resource "kubectl_manifest" "tekton_operator_kustomization" {
  yaml_body = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: tekton-operator
  namespace: ${kubernetes_namespace.tekton_operator.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  prune: true
  path: /config/kubernetes/overlays/default
  targetNamespace: ${kubernetes_namespace.tekton_operator.metadata[0].name}
  sourceRef:
    kind: GitRepository
    name: tekton-operator
    namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  patches:
    - patch: |-
        apiVersion: v1
        kind: Deployment
        metadata:
          name: tekton-operator
        spec:
          template:
            spec:
              containers:
                - name: tekton-operator
                  image: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/operator:${local.tekton.operator.version}
                  imagePullPolicy: IfNotPresent
                  env:
                    - name: IMAGE_PIPELINES_PROXY
                      value: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/proxy-webhook:${local.tekton.operator.version}
      target:
        kind: Deployment
        name: tekton-operator
    - patch: |-
        apiVersion: v1
        kind: Deployment
        metadata:
          name: tekton-operator-webhook
        spec:
          template:
            spec:
              containers:
                - name: tekton-operator-webhook
                  image: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/webhook:${local.tekton.operator.version}
                  imagePullPolicy: IfNotPresent
      target:
        kind: Deployment
        name: tekton-operator-webhook
    - patch: |-
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: tekton-config-defaults
        data:
          AUTOINSTALL_COMPONENTS: "false"
      target:
        kind: ConfigMap
        name: tekton-config-defaults
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.tekton_operator_git_repository
  ]
}

resource "kubernetes_namespace" "tekton_operator" {
  metadata { name = "tekton-operator" }
  lifecycle {
    ignore_changes = [
      metadata
    ]
  }
}
