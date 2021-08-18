ifneq (,$(wildcard ./.env))
	include .env
	export $(shell sed 's/=.*//' .env)
endif

.PHONY: help

help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

init: ## Initialize Terraform configurations
	terraform init

up: ## Starts a Kubernetes cluster running local using Docker containers and apply all solution components
	terraform apply -auto-approve

down: ## Uninstall all solution components and destroy the local Kubernetes cluster
	terraform destroy -auto-approve

plan:
	terraform plan

clean:
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* openssh-config

connect:
	nohup kubectl port-forward openssh-server 2222:22 >/dev/null 2>&1 &
	ssh -i ./ssh/id_rsa -p 2222 root@127.0.0.1
