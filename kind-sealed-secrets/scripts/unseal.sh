#!/bin/bash

kubeseal --recovery-unseal --recovery-private-key "./tmp/certificates/tls.key" <<EOF
    apiVersion: bitnami.com/v1alpha1
    kind: SealedSecret
    metadata:
      labels:
        argocd.argoproj.io/instance: github-webhooks
      name: github-access
      namespace: continuous-deployment
    spec:
      encryptedData:
        token: AgAhtMsRcyyIK/fn2OM/tyMm6x2UYk08Kp8XVCFAN9Uw4feR/7LRjyJCOB+R0fmy0tECYt6JKBe1P8ub4LCcs1W5DRgsv016Bs5t228RohdDB38PY5rYr/TV9Hla/13+aRVJyPce6SIv4KAeVzW/LatDfq7EsEv99x57bPBxCV30nvOUGJgJHyB3pynfQxvB4SzvzCIMle6lVHynWQkuZr/LxzHcILgfWsCLO+2jV82UxVI1vwxxLMNvbLy000eXFzcH9vx4/Kl3mL6z/1Lnl7J/78H2TACHlqQiyqMRPm+16Pw5j2W3hgBdF02NokRSR+xfQowkXdW380em6w4OOV4XqbdvTNGFJMxhLfuWSH8WAhOENUzZD6zIQINVN1lO9F0VTzi7tysNArfubmJAfVsahDHZa1Uwri5lU+C8P/NZ6LT4knE584SHz+u9fKoUQqurRUo2avPjXCw6z4z3Mwth+57qYovNyFP8cvMaPATzv2bbxdZmLAgqrrISxLwIUg5gcDIG3BPzw5EmekTWA2sGKTK0o77432tXew/J5CCr8ELD0isuF+mHp09KNIDE2JooLWUnYEhQG4MPLm1ukicrXwgoBBLrR5WASlW+NZ9tsm3ylcpG5XxBxZFOaha6MrCqXlSbW3LjLp1c6J8ibGmAI01QXIx8YuRvbYWR6yZ+HSoZWRHJX5Q7k2UZYb8fPwbqzN8z6q0j+v7RKNmSapFILoX5BGWZQKRS/BCmN+PYBJ4S+wWrNh2o
      template:
        metadata:
          name: github-access
        type: Opaque
EOF