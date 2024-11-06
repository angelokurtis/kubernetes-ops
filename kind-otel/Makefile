ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: init
init: ## Set up Terraform with latest updates.
	terraform init -upgrade=true

.PHONY: quickstart
quickstart: init ## Run setup, load images, and apply all configurations.
	terraform apply -auto-approve -target=kind_cluster.otel
	scripts/loadimages.sh
	terraform apply -auto-approve

.PHONY: plan
plan: ## Show planned changes without applying.
	terraform plan

.PHONY: apply
apply: ## Apply all configurations to start the cluster.
	terraform apply -auto-approve

.PHONY: down
down: clean ## Remove cluster and components.
	kind delete cluster --name otel

.PHONY: clean
clean: ## Delete generated Terraform files.
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* otel-config
