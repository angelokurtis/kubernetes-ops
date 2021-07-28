#!/bin/bash

kubeseal --controller-namespace=encryption --controller-name=sealed-secrets -o=yaml >mysecret.yaml <<EOF
    apiVersion: v1
    kind: Secret
    metadata:
      name: mysecret
    type: Opaque
    data:
      password: $(echo -n "s33msi4" | base64 -w0)
      username: $(echo -n "jane" | base64 -w0)
EOF