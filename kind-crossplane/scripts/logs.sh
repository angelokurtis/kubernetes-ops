#!/usr/bin/env bash

set -euo pipefail

kubectl stern -n crossplane -c '^(package-runtime)$' '^(crossplane-provider-opentofu-.*)$' .
