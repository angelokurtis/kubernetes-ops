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
    --from-literal=managementPassword="cRF5mz:2oLKHdeT"
  
helm upgrade -i keycloak bitnami/keycloak --version 5.0.7 -n iam -f - <<EOF
    auth: 
      adminUser: admin
      existingSecretPerPassword: 
        adminPassword: 
          name: keycloak-passwords
        databasePassword: 
          name: keycloak-passwords
        managementPassword: 
          name: keycloak-passwords
    externalDatabase: 
      existingSecret: database-env-vars
    image: 
      repository: bitnami/keycloak
      tag: "15.0.2"
    ingress: 
      annotations: 
        kubernetes.io/ingress.class: istio
      enabled: true
      hostname: keycloak.lvh.me
      pathType: Prefix
    nameOverride: keycloak
    postgresql: 
      enabled: false
    service: 
      type: ClusterIP
EOF
```

### Initialize Keycloak realm, clients and users

```shell
# authorize with username / password
ACCESS_TOKEN=$(curl -s 'http://keycloak.lvh.me/auth/realms/master/protocol/openid-connect/token' \
    --header 'Content-Type: application/x-www-form-urlencoded' \
    --data-urlencode 'client_id=admin-cli' \
    --data-urlencode 'client_secret=a=Dg0>PGyscSNu)i' \
    --data-urlencode 'grant_type=password' \
    --data-urlencode 'username=admin' \
    --data-urlencode 'password=:gjUzkk{:h2bPB_6' \
    | jq '.access_token' -r)

# create realm
curl -X POST 'http://keycloak.lvh.me/auth/admin/realms' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw '{"enabled":true,"id":"charlescd","realm":"charlescd"}'

# create public client
curl -X POST 'http://keycloak.lvh.me/auth/admin/realms/charlescd/clients' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw '{"clientId":"charlescd-client","directAccessGrantsEnabled":true,"implicitFlowEnabled":true,"publicClient":true,"redirectUris":["http://charles.lvh.me/*"],"serviceAccountsEnabled":true,"webOrigins":["*"]}'

# create confidential client
curl -X POST 'http://keycloak.lvh.me/auth/admin/realms/charlescd/clients' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw '{"clientId":"realm-charlescd","secret":"vO]i?GSWWr0$zIZR","serviceAccountsEnabled":true,"standardFlowEnabled":false}'

# create admin user
curl -X POST 'http://keycloak.lvh.me/auth/admin/realms/charlescd/users' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw '{"username":"charlesadmin@admin","enabled":true,"emailVerified":true,"email":"charlesadmin@admin","attributes":{"isRoot":["true"]}}'

# get admin user identifier
USER_ID=$(curl -s 'http://keycloak.lvh.me/auth/admin/realms/charlescd/users?username=charlesadmin@admin' \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    | jq '.[0].id' -r)

# create admin credentials
curl -X PUT "http://keycloak.lvh.me/auth/admin/realms/charlescd/users/${USER_ID}/reset-password" \
    --header "Authorization: Bearer ${ACCESS_TOKEN}" \
    --header 'Content-Type: application/json' \
    --data-raw '{"type":"password","value":"g_wl!U8Uyf2)$KKw","temporary":false}'
```

### Deploy CharlesCD

```shell
export CHARLESCD_VERSION=1.0.1

kubectl create namespace continuous-deployment

curl https://github.com/ZupIT/charlescd/archive/refs/tags/${CHARLESCD_VERSION}.zip -OJL
unzip ./charlescd-${CHARLESCD_VERSION}.zip
( cd ./charlescd-${CHARLESCD_VERSION}/install/helm-chart ; helm dependency update )

helm upgrade -i charlescd ./charlescd-${CHARLESCD_VERSION}/install/helm-chart -n continuous-deployment \
    --set CharlesApplications.butler.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.butler.database.name="charlescd_butler_db" \
    --set CharlesApplications.butler.database.password="fNq1milqfZI6v3aU" \
    --set CharlesApplications.butler.database.user="charlescd_butler" \
    --set CharlesApplications.butler.healthCheck.initialDelay="5" \
    --set CharlesApplications.butler.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.butler.pullPolicy="IfNotPresent" \
    --set CharlesApplications.butler.resources.limits=null \
    --set CharlesApplications.circleMatcher.allowedOriginHost="http://charles.lvh.me" \
    --set CharlesApplications.circleMatcher.healthCheck.initialDelay="5" \
    --set CharlesApplications.circleMatcher.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.circleMatcher.pullPolicy="IfNotPresent" \
    --set CharlesApplications.circleMatcher.redis.host="redis-master.cache.svc.cluster.local" \
    --set CharlesApplications.circleMatcher.redis.password="V5waJ0OXte16WCR3" \
    --set CharlesApplications.circleMatcher.resources.limits=null \
    --set CharlesApplications.compass.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.compass.database.name="charlescd_compass_db" \
    --set CharlesApplications.compass.database.password="5Pzmuji7NFYJAazk" \
    --set CharlesApplications.compass.database.user="charlescd_compass" \
    --set CharlesApplications.compass.healthCheck.initialDelay="5" \
    --set CharlesApplications.compass.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.compass.moove.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.compass.moove.database.name="charlescd_moove_db" \
    --set CharlesApplications.compass.moove.database.password="GnozoAWuCGoIYF6Z" \
    --set CharlesApplications.compass.moove.database.user="charlescd_moove" \
    --set CharlesApplications.compass.pullPolicy="IfNotPresent" \
    --set CharlesApplications.compass.resources.limits=null \
    --set CharlesApplications.gate.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.gate.database.name="charlescd_moove_db" \
    --set CharlesApplications.gate.database.password="GnozoAWuCGoIYF6Z" \
    --set CharlesApplications.gate.database.user="charlescd_moove" \
    --set CharlesApplications.gate.healthCheck.initialDelay="5" \
    --set CharlesApplications.gate.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.gate.pullPolicy="IfNotPresent" \
    --set CharlesApplications.gate.resources.limits=null \
    --set CharlesApplications.hermes.amqp.url="amqp://user:dI5FYfnN33i9xA9#@rabbitmq.queue.svc.cluster.local:5672/" \
    --set CharlesApplications.hermes.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.hermes.database.name="charlescd_hermes_db" \
    --set CharlesApplications.hermes.database.password="SN1rLfyMG96CzZyl" \
    --set CharlesApplications.hermes.database.user="charlescd_hermes" \
    --set CharlesApplications.hermes.healthCheck.initialDelay="5" \
    --set CharlesApplications.hermes.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.hermes.pullPolicy="IfNotPresent" \
    --set CharlesApplications.hermes.resources.limits=null \
    --set CharlesApplications.moove.allowedOriginHost="http://charles.lvh.me" \
    --set CharlesApplications.moove.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.moove.database.name="charlescd_moove_db" \
    --set CharlesApplications.moove.database.password="GnozoAWuCGoIYF6Z" \
    --set CharlesApplications.moove.database.user="charlescd_moove" \
    --set CharlesApplications.moove.healthCheck.initialDelay="5" \
    --set CharlesApplications.moove.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.moove.pullPolicy="IfNotPresent" \
    --set CharlesApplications.moove.resources.limits=null \
    --set CharlesApplications.ui.allowedOriginHost="http://charles.lvh.me" \
    --set CharlesApplications.ui.apiHost="http://charles.lvh.me" \
    --set CharlesApplications.ui.authUri="http://keycloak.lvh.me" \
    --set CharlesApplications.ui.healthCheck.initialDelay="5" \
    --set CharlesApplications.ui.idmRedirectHost="http://charles.lvh.me" \
    --set CharlesApplications.ui.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.ui.pullPolicy="IfNotPresent" \
    --set CharlesApplications.ui.resources.limits=null \
    --set CharlesApplications.villager.database.host="postgresql.database.svc.cluster.local" \
    --set CharlesApplications.villager.database.name="charlescd_villager_db" \
    --set CharlesApplications.villager.database.password="pnvvseJ8BW2jNsrc" \
    --set CharlesApplications.villager.database.user="charlescd_villager" \
    --set CharlesApplications.villager.healthCheck.initialDelay="5" \
    --set CharlesApplications.villager.image.tag="${CHARLESCD_VERSION}" \
    --set CharlesApplications.villager.pullPolicy="IfNotPresent" \
    --set CharlesApplications.villager.resources.limits=null \
    --set envoy.idm.endpoint="keycloak.lvh.me" \
    --set envoy.idm.path="/auth/realms/charlescd/protocol/openid-connect/userinfo" \
    --set hostGlobal="http://charles.lvh.me" \
    --set ingress.enabled="false" \
    --set keycloak.enabled="false" \
    --set nginx_ingress_controller.enabled="false" \
    --set postgresql.enabled="false" \
    --set rabbitmq.enabled="false" \
    --set redis.enabled="false"
```

```shell
kubectl apply -f - <<EOF
    apiVersion: networking.k8s.io/v1
    kind: Ingress
    metadata:
      annotations:
        kubernetes.io/ingress.class: istio
      name: charlescd
      namespace: continuous-deployment
    spec:
      rules:
        - host: charles.lvh.me
          http:
            paths:
              - backend:
                  service:
                    name: envoy-proxy
                    port:
                      number: 80
                path: /
                pathType: Prefix
EOF
```