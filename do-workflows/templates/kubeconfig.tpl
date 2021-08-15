apiVersion: v1
clusters:
- cluster:
    certificate-authority-data: ${cluster.certificate_authority}
    server: ${cluster.endpoint}
  name: ${cluster.name}
contexts:
- context:
    cluster: ${cluster.name}
    user: ${user.name}
  name: ${cluster.name}
current-context: ${cluster.name}
kind: Config
preferences: {}
users:
- name: ${user.name}
  user:
    client-certificate-data: ${user.crt}
    client-key-data: ${user.key}
