# Deploying CharlesCD on Kubernetes with KinD

## Create Kubernetes clusters with KinD

```shell
cat <<EOF | kind create cluster --name charles-testing --config=-
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
nodes:
- role: control-plane
  image: kindest/node:v1.20.7
  kubeadmConfigPatches:
  - |
    kind: InitConfiguration
    nodeRegistration:
      kubeletExtraArgs:
        node-labels: "ingress-ready=true"
  extraPortMappings:
  - containerPort: 30000
    hostPort: 80
    protocol: TCP
  - containerPort: 30001
    hostPort: 443
    protocol: TCP
  - containerPort: 30002
    hostPort: 15021
    protocol: TCP
EOF
```

## Install Istio on Kubernetes

### Install Istio Operator

```shell
export ISTIO_VERSION=1.7.8
curl -L https://istio.io/downloadIstio | sh -
helm upgrade -i istio-operator ./istio-${ISTIO_VERSION}/manifests/charts/istio-operator \
    --set watchedNamespaces="istio-system" \
    --set hub="docker.io/istio" \
    --set tag="${ISTIO_VERSION}-distroless"
```

### Install Istio and configure Istio Ingress as NodePort

```shell
kubectl create namespace istio-system
kubectl apply -f - <<EOF
apiVersion: install.istio.io/v1alpha1
kind: IstioOperator
metadata:
  name: control-plane
  namespace: istio-system
spec:
  profile: demo
  components:
    egressGateways:
      - enabled: false
        name: istio-egressgateway
    ingressGateways:
      - enabled: true
        k8s:
          nodeSelector:
            ingress-ready: "true"
          service:
            ports:
              - name: status-port
                nodePort: 30002
                port: 15021
                targetPort: 15021
              - name: http2
                nodePort: 30000
                port: 80
                targetPort: 8080
              - name: https
                nodePort: 30001
                port: 443
                targetPort: 8443
        name: istio-ingressgateway
  values:
    gateways:
      istio-ingressgateway:
        type: NodePort
    global:
      defaultPodDisruptionBudget:
        enabled: false
      logging:
        level: "default:debug"
      proxy:
        componentLogLevel: "misc:debug"
        logLevel: debug
EOF
```

```shell
curl http://localhost:15021/healthz/ready -I
```

## Deploying applications packaged by Bitnami Helm Charts

```shell
helm repo add bitnami https://charts.bitnami.com/bitnami
```

### Deploy Redis

```shell
kubectl create namespace cache
kubectl create secret generic redis -n cache --from-literal=password=cmXeuBSE6ElcCnEH
helm upgrade -i redis bitnami/redis -n cache \
    --set architecture="standalone" \
    --set auth.existingSecret="redis" \
    --set auth.existingSecretPasswordKey="password" \
    --set image.tag="6.2" \
    --set nameOverride="redis"
```

### Deploy RabbitMQ

```shell
kubectl create namespace queue
helm upgrade -i rabbitmq bitnami/rabbitmq -n queue \
    --set auth.erlangCookie="%d_3uIt&B7qyh2Gc" \
    --set auth.password="dI5FYfnN33i9xA9#" \
    --set image.tag="3.9"
```
