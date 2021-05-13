.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

init: ## Initialize Terraform configurations
	terraform init

up: ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform apply -auto-approve -var-file=testing.tfvars

down: ## Uninstall all solution components and destroy the local Kubernetes cluster
	terraform destroy -auto-approve -var-file=testing.tfvars

plan:
	terraform plan -var-file=testing.tfvars

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* horusec-config

template-manager:
	helm template manager /home/tiagoangelo/wrkspc/github.com/ZupIT/horusec/horusec-manager/deployments/helm/horusec-manager -f ./values/manager.yaml -n horusec > manifests.yaml

template-auth:
	helm template auth /home/tiagoangelo/wrkspc/github.com/ZupIT/horusec/horusec-auth/deployments/helm/horusec-auth -f ./values/auth.yaml -n horusec > manifests.yaml