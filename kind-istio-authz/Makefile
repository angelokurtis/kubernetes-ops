.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

init: ## Initialize Terraform configurations
	terraform init -upgrade=true

plan: init ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform plan -var-file="testing.tfvars"

up: init ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform apply -auto-approve -var-file="testing.tfvars"

down: clean ## Uninstall all solution components and destroy the local Kubernetes cluster
	kind delete clusters istio-cluster

clean: ## Removing all Terraform generated config files
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* istio-cluster-config
