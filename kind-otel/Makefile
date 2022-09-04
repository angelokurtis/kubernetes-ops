ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: init
init: ## Initialize Terraform configurations
	terraform init -upgrade=true

.PHONY: quickstart
quickstart: init ## Initialize Terraform configurations
	terraform apply -auto-approve -target=kind_cluster.otel
	scripts/loadimages.sh
	terraform apply -auto-approve

.PHONY: plan
plan: ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform plan

.PHONY: apply
apply: ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform apply -auto-approve

.PHONY: down
down: clean ## Uninstall all solution components and destroy the local Kubernetes cluster
	kind delete cluster --name otel

.PHONY: clean
clean: ## Removing all Terraform generated config files
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* otel-config
