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

local_clean: ## Delete all local devops-tools images
	docker images --filter='reference=devops-tools' --format='{{.Repository}}:{{.Tag}}' | xargs docker rmi --force

bump: ## bump version:  make PART=patch bump
	rm -rf .venv
	python3 -m venv .venv
	( \
			source path/to/virtualenv/activate; \
			pip install --upgrade pip setuptools; \
			pip install bump2version; \
			bump2version $(PART); \
	)
