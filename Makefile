.PHONY: lint pre_build_test help
.DEFAULT_GOAL := help

VERSION := 0.0.9
COMMIT_HASH := $(shell git rev-parse --short HEAD)

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

rm_venv:
	rm -rf .venv

mk_venv: rm_venv
	python3 -m venv .venv

python_clean:
	find . -name '*.pyc' -exec rm -f {} \;
	find . -name '*.pyo' -exec rm -f {} \;
	find . -name '__pycache__' -exec rm -rf {} \;
	find . -name '*~' -exec rm -f  {} \;


docker-clean: ## remove all local docker images
	-docker rmi -f $(docker images | grep devops-tools | tr -s ' ' | cut -d ' ' -f 3)

git-status: ## Checks git status before executing build steps
	@status=$$(git status --porcelain); \
	if [ ! -z "$${status}" ]; \
	then \
		echo "Error - working directory is dirty. Commit those changes!"; \
		exit 1; \
	fi

lint: mk_venv  ## Run static code checks
	@echo Run static code checks
	shellcheck scripts/*.sh

test: lint ## run tests before building the docker container
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install pytest pytest-testinfra; \
			python3 -m pytest ./test/test_pre_build.py;\
	)

post_build_test: rm_venv mk_venv ## Run post build docker tests
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install pytest pytest-testinfra; \
			python3 -m pytest ./test/test_post_build.py;\
	)

local_docker_build: test ## build the docker image locally with latest/hash tag
	@echo Run static code checks
	docker build --tag devops-tools:latest --tag devops-tools:$(COMMIT_HASH) .

local_build:  local_docker_build post_build_test

local_clean: ## Delete all local devops-tools images
	docker images --filter='reference=devops-tools' --format='{{.Repository}}:{{.Tag}}' | xargs docker rmi --force

bump: test ## bump version:  make PART=patch bump
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install bump2version; \
			bump2version $(PART); \
	)

docker-login:
	$$(aws ecr get-login --no-include-email  --region us-east-1)

build_release_image:
	( \
       docker build --tag devops-tools:latest --tag devops-tools:$(VERSION) .; \
    )

upload_release_images: build_release_image post_build_test docker-login ## push images to registry and upload python package to artifacts
	( \
       docker tag devops-tools:latest 151924297945.dkr.ecr.us-east-1.amazonaws.com/devops-tools; \
       docker tag devops-tools:$(VERSION) 151924297945.dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(VERSION); \
       docker push 151924297945.dkr.ecr.us-east-1.amazonaws.com/devops-tools:latest; \
       docker push 151924297945.dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(VERSION); \
    )