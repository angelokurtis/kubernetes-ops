.PHONY: help
help: ## This help.
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

.DEFAULT_GOAL := help

.PHONY: up ## Initialize and apply Terraform configurations.
up: init apply

.PHONY: init
init: godotenv ## Set up OpenTofu with latest updates.
	@$(GODOTENV) -o tofu init -upgrade=true -input=false

.PHONY: plan
plan: godotenv ## Show planned changes without applying.
	@$(GODOTENV) -o tofu plan -out=tfplan -input=false -show-sensitive
	@TF_BINARY=tofu tf-summarize tfplan

.PHONY: apply
apply: godotenv ## Apply all configurations to start the cluster.
	@$(GODOTENV) -o tofu apply -input=false tfplan

.PHONY: output
output: godotenv ## Show Keycloak access info (URL, user, password)
	@$(GODOTENV) -o tofu output keycloak_access_info

.PHONY: down
down: clean ## Remove cluster and components.
	kind delete cluster --name keycloak

.PHONY: clean
clean: ## Delete generated OpenTofu files.
	rm -rf .terraform .terraform.lock.hcl terraform.tfstate* keycloak-config

##@ Dependencies

## Location to install dependencies to
LOCALBIN ?= $(shell pwd)/bin
$(LOCALBIN):
	mkdir -p $(LOCALBIN)

## Tool Binaries
GODOTENV = $(LOCALBIN)/godotenv

## Tool Versions
GODOTENV_VERSION ?= v1.5.1

.PHONY: godotenv
godotenv: $(GODOTENV) ## Download godotenv locally if necessary.
$(GODOTENV): $(LOCALBIN)
	$(call go-install-tool,$(GODOTENV),github.com/joho/godotenv/cmd/godotenv,$(GODOTENV_VERSION))

# go-install-tool will 'go install' any package with custom target and name of binary, if it doesn't exist
# $1 - target path with name of binary
# $2 - package url which can be installed
# $3 - specific version of package
define go-install-tool
@[ -f "$(1)-$(3)" ] || { \
set -e; \
package=$(2)@$(3) ;\
echo "Downloading $${package}" ;\
rm -f $(1) || true ;\
GOBIN=$(LOCALBIN) go install $${package} ;\
mv $(1) $(1)-$(3) ;\
} ;\
ln -sf $(1)-$(3) $(1)
endef
