#!/bin/bash

set -e

export HORUSEC_VERSION=2.16.4
curl -fsLo horusec-platform-${HORUSEC_VERSION}.zip https://github.com/ZupIT/horusec-platform/archive/refs/tags/v${HORUSEC_VERSION}.zip
unzip horusec-platform-${HORUSEC_VERSION}.zip horusec-platform-${HORUSEC_VERSION}/deployments/helm/horusec-platform/*
tar -czvf horusec-platform.tar.gz -C horusec-platform-${HORUSEC_VERSION}/deployments/helm/horusec-platform ./
rm -rf horusec-platform-${HORUSEC_VERSION}.zip horusec-platform-${HORUSEC_VERSION}
