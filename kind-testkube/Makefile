ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: init
init: ## Set up OpenTofu with latest updates.
	tofu init -upgrade=true -input=false

.PHONY: plan
plan: ## Show planned changes without applying.
	tofu plan -out=tfplan -input=false
	TF_BINARY=tofu tf-summarize tfplan

.PHONY: apply
apply: ## Apply all configurations to start the cluster.
	tofu apply -input=false tfplan

.PHONY: down
down: clean ## Remove cluster and components.
	kind delete cluster --name testkube

.PHONY: clean
clean: ## Delete generated OpenTofu files.
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* testkube-config
