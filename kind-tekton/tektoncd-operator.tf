resource "kubectl_manifest" "tektoncd_operator_kustomization" {
  yaml_body = <<YAML
apiVersion: kustomize.toolkit.fluxcd.io/v1beta2
kind: Kustomization
metadata:
  name: tektoncd-operator
  namespace: ${kubernetes_namespace.tektoncd.metadata[0].name}
spec:
  interval: ${local.fluxcd.default_interval}
  prune: true
  path: /config/kubernetes/overlays/default
  targetNamespace: ${kubernetes_namespace.tektoncd.metadata[0].name}
  sourceRef:
    kind: GitRepository
    name: tektoncd-operator
    namespace: ${kubernetes_namespace.fluxcd.metadata[0].name}
  patches:
    - patch: |-
        apiVersion: v1
        kind: Service
        metadata:
          name: tekton-operator
          labels:
            version: ${local.tektoncd.operator.version}
      target:
        kind: Service
        name: tekton-operator

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektonchains.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektonchains.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektonconfigs.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektonconfigs.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektondashboards.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektondashboards.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektonhubs.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektonhubs.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektoninstallersets.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektoninstallersets.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektonpipelines.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektonpipelines.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektonresults.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektonresults.operator.tekton.dev

    - patch: |-
        apiVersion: apiextensions.k8s.io/v1
        kind: CustomResourceDefinition
        metadata:
          name: tektontriggers.operator.tekton.dev
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: CustomResourceDefinition
        name: tektontriggers.operator.tekton.dev

    - patch: |-
        apiVersion: v1
        kind: ConfigMap
        metadata:
          name: tekton-operator-info
        data:
          version: ${local.tektoncd.operator.version}
      target:
        kind: ConfigMap
        name: tekton-operator-info

    - patch: |-
        apiVersion: v1
        kind: Service
        metadata:
          name: tekton-operator-webhook
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
      target:
        kind: Service
        name: tekton-operator-webhook

    - patch: |-
        apiVersion: v1
        kind: Deployment
        metadata:
          name: tekton-operator
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
        spec:
          template:
            spec:
              containers:
                - name: tekton-operator
                  image: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/operator:${trimprefix(local.tektoncd.operator.version, "v")}
                  env:
                    - name: IMAGE_PIPELINES_PROXY
                      value: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/proxy-webhook:${trimprefix(local.tektoncd.operator.version, "v")}
                    - name: VERSION
                      value: ${local.tektoncd.operator.version}
      target:
        kind: Deployment
        name: tekton-operator

    - patch: |-
        apiVersion: v1
        kind: Deployment
        metadata:
          name: tekton-operator-webhook
          labels:
            operator.tekton.dev/release: ${local.tektoncd.operator.version}
            version: ${local.tektoncd.operator.version}
        spec:
          template:
            spec:
              containers:
                - name: tekton-operator-webhook
                  image: gcr.io/tekton-releases/github.com/tektoncd/operator/cmd/kubernetes/webhook:${trimprefix(local.tektoncd.operator.version, "v")}
      target:
        kind: Deployment
        name: tekton-operator-webhook

    - patch: |-
        apiVersion: rbac.authorization.k8s.io/v1
        kind: ClusterRoleBinding
        metadata:
          name: tekton-operator
        subjects:
          - kind: ServiceAccount
            name: tekton-operator
            namespace: ${kubernetes_namespace.tektoncd.metadata[0].name}
      target:
        kind: ClusterRoleBinding
        name: tekton-operator
YAML

  depends_on = [
    kubectl_manifest.fluxcd,
    kubectl_manifest.tektoncd_operator_git_repository
  ]
}

resource "kubernetes_namespace" "tektoncd" {
  metadata { name = "tektoncd" }
}
