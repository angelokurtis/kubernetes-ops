# Deploying CharlesCD on Kubernetes with KinD

## Create Kubernetes clusters with KinD

```shell
cat <<EOF | kind create cluster --name "charles-testing" --config=-
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

kubectl create secret generic redis -n cache --from-literal=password="cmXeuBSE6ElcCnEH"

helm upgrade -i redis bitnami/redis --version 15.3.2 -n cache \
    --set architecture="standalone" \
    --set auth.existingSecret="redis" \
    --set auth.existingSecretPasswordKey="password" \
    --set image.tag="6.2" \
    --set nameOverride="redis"
```

### Deploy RabbitMQ

```shell
kubectl create namespace queue

helm upgrade -i rabbitmq bitnami/rabbitmq --version 8.22.0 -n queue \
    --set auth.erlangCookie="%d_3uIt&B7qyh2Gc" \
    --set auth.password="dI5FYfnN33i9xA9#" \
    --set image.tag="3.9"
```

### Deploy PostgreSQL

```shell
cat << EOF > ./userdata.sql
    -- CharlesCD Moove
    create database charlescd_moove_db;
    create user charlescd_moove with encrypted password 'GnozoAWuCGoIYF6Z';
    alter user charlescd_moove with superuser;
    grant all privileges on database charlescd_moove_db to charlescd_moove;

    -- CharlesCD Villager
    create database charlescd_villager_db;
    create user charlescd_villager with encrypted password 'pnvvseJ8BW2jNsrc';
    alter user charlescd_villager with superuser;
    grant all privileges on database charlescd_villager_db to charlescd_villager;

    -- CharlesCD Butler
    create database charlescd_butler_db;
    create user charlescd_butler with encrypted password 'fNq1milqfZI6v3aU';
    alter user charlescd_butler with superuser;
    grant all privileges on database charlescd_butler_db to charlescd_butler;

    -- CharlesCD Hermes
    create database charlescd_hermes_db;
    create user charlescd_hermes with encrypted password 'SN1rLfyMG96CzZyl';
    alter user charlescd_hermes with superuser;
    grant all privileges on database charlescd_hermes_db to charlescd_hermes;

    -- CharlesCD Compass
    create database charlescd_compass_db;
    create user charlescd_compass with encrypted password '5Pzmuji7NFYJAazk';
    alter user charlescd_compass with superuser;
    grant all privileges on database charlescd_compass_db to charlescd_compass;

    -- CharlesCD Keycloak
    create database keycloak_db;
    create user keycloak with encrypted password 'seDnCGd3cz8G5QCy';
    alter user keycloak with superuser;
    grant all privileges on database keycloak_db to keycloak;
EOF
```

```shell
kubectl create namespace database

kubectl create secret generic userdata --from-file="./userdata.sql"

helm upgrade -i postgresql bitnami/postgresql --version 10.9.5 -n database \
    --set fullnameOverride="postgresql" \
    --set image.tag="13" \
    --set initdbScriptsSecret="userdata"
```

### Deploy Keycloak

```shell
kubectl create namespace iam

kubectl create secret generic database-env-vars -n iam \
    --from-literal=KEYCLOAK_DATABASE_HOST="postgresql.database.svc.cluster.local" \
    --from-literal=KEYCLOAK_DATABASE_NAME="keycloak_db" \
    --from-literal=KEYCLOAK_DATABASE_PORT="5432" \
    --from-literal=KEYCLOAK_DATABASE_USER="keycloak"

kubectl create secret generic keycloak-passwords -n iam \
    --from-literal=adminPassword=":gjUzkk{:h2bPB_6" \
    --from-literal=databasePassword="seDnCGd3cz8G5QCy" \
    --from-literal=managementPassword="cRF!5mz:2oLKHdeT"
  
helm upgrade -i keycloak bitnami/keycloak --version 5.0.7 -n iam \
    --set auth.adminUser="admin" \
    --set auth.existingSecretPerPassword.adminPassword.name="keycloak-passwords" \
    --set auth.existingSecretPerPassword.databasePassword.name="keycloak-passwords" \
    --set auth.existingSecretPerPassword.managementPassword.name="keycloak-passwords" \
    --set externalDatabase.existingSecret="database-env-vars" \
    --set image.repository="bitnami/keycloak" \
    --set image.tag="15.0.2" \
    --set ingress.annotations.kubernetes.io/ingress.class="istio" \
    --set ingress.enabled="true" \
    --set ingress.hostname="keycloak.lvh.me" \
    --set ingress.pathType="Prefix" \
    --set nameOverride="keycloak" \
    --set postgresql.enabled="false" \
    --set service.type="ClusterIP"
```