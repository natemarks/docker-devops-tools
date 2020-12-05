.PHONY: clean help
.DEFAULT_GOAL := help

COMMIT_HASH := $(shell git rev-parse --short HEAD)

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

git-status: ## Checks git status before executing build steps
	@status=$$(git status --porcelain); \
	if [ ! -z "$${status}" ]; \
	then \
		echo "Error - working directory is dirty. Commit those changes!"; \
		exit 1; \
	fi

lint: git-status ## Run static code checks
	@echo Run static code checks
	shellcheck scripts/*.sh

local_build: lint ## Run static code checks
	@echo Run static code checks
	docker build --tag devops-tools:dev-latest --tag devops-tools:dev-$(COMMIT_HASH) .