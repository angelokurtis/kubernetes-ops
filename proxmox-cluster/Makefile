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
	tofu init -upgrade=true -input=false

.PHONY: plan
plan: ## Show planned changes without applying.
	tofu plan -out=tfplan -input=false
	TF_BINARY=tofu tf-summarize tfplan

.PHONY: apply
apply: ## Apply all configurations to start the cluster.
	tofu apply -input=false tfplan

.PHONY: plan-destroy
plan-destroy: ## Create and show a destroy plan.
	tofu plan -destroy -out=tfplan-destroy -input=false
	TF_BINARY=tofu tf-summarize tfplan-destroy || true

.PHONY: destroy
destroy: ## Apply the destroy plan.
	tofu apply -input=false tfplan-destroy

.PHONY: clean
clean: ## Delete generated Terraform files.
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* tfplan*
	find . -type d -empty -delete
