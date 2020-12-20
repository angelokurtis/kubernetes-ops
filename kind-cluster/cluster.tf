resource "kind_cluster" "istio" {
  name = "istio"
  node_image = "kindest/node:v1.18.8"
  kind_config = <<KIONF
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30000
    hostPort: 80
  - containerPort: 30001
    hostPort: 443
  - containerPort: 30002
    hostPort: 15021
KIONF
}