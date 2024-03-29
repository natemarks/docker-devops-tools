.PHONY: lint pre_build_test help
.DEFAULT_GOAL := help

VERSION := 0.0.46
COMMIT_HASH := $(shell git rev-parse HEAD)
MAIN_BRANCH := master

help: ## Show this help.
	@fgrep -h "##" $(MAKEFILE_LIST) | fgrep -v fgrep | sed -e 's/\\$$//' | sed -e 's/##//'

rm_venv: ## use clean-venv instead
	rm -rf .venv

clean-venv: rm_venv  ## delete and recreate venv
	python3 -m venv .venv
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install -r requirements.txt; \
	)

python_clean: ## delete python cache files, pyc etc
	find . -name '*.pyc' -exec rm -f {} \;
	find . -name '*.pyo' -exec rm -f {} \;
	find . -name '__pycache__' -exec rm -rf {} \;
	find . -name '*~' -exec rm -f  {} \;

docker-clean: ## Delete all local devops-tools images
	docker images --filter='reference=devops-tools' --format='{{.Repository}}:{{.Tag}}' | xargs docker rmi --force

git-status: ## Checks git status before executing build steps
	@status=$$(git status --porcelain); \
	if [ ! -z "$${status}" ]; \
	then \
		echo "Error - working directory is dirty. Commit those changes!"; \
		exit 1; \
	fi

shellcheck: ## Run static code checks
	@echo Run shellcheck against scripts/
	shellcheck scripts/*.sh

pylint: ## Run static code checks
	@echo Run pylint against scripts/
	( \
			. .venv/bin/activate; \
			pylint scripts; \
	)

blacken: ## Use black to reformat files
	@echo Run blacken against scripts/
	( \
			. .venv/bin/activate; \
			black --line-length 79 scripts; \
	)

black_check: ## Run black in check mode
	@echo Run blacken against scripts/
	( \
			. .venv/bin/activate; \
			black --check --line-length 79 scripts; \
	)
static-checks: clean-venv shellcheck pylint black_check ## Run all local static checks

test: static-checks ## run tests before building the docker container
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install -r requirements.txt; \
			python3 -m pytest ./test_pre_build.py;\
	)

post_build_test: clean-venv ## Run post build docker tests
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install pytest pytest-testinfra; \
			python3 -m pytest ./test_post_build.py;\
	)

local_docker_build: test ## build the docker image locally with latest/hash tag
	@echo Run static code checks
	docker build --tag devops-tools:latest --tag devops-tools:$(COMMIT_HASH) .

local_build:  local_docker_build post_build_test

bump: git-status test ## bump version:  make part=patch bump
	( \
			. .venv/bin/activate; \
			pip install --upgrade pip setuptools; \
			pip install bump2version; \
			bump2version $(part); \
	)

docker-login:
	$$(aws ecr get-login --no-include-email  --region us-east-1)

build_release_image:
	( \
       docker build --tag devops-tools:latest --tag devops-tools:$(VERSION) .; \
    )

upload_release_images: build_release_image post_build_test docker-login ## push images to registry and upload python package to artifacts
	( \
       docker tag devops-tools:$(VERSION) $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(VERSION); \
       docker push $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(VERSION); \
    )

upload_dev_images: local_build ## push images to registry and upload python package to artifacts
	( \
       docker tag devops-tools:$(COMMIT_HASH) $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(COMMIT_HASH); \
       docker push $(AWS_ACCOUNT_ID).dkr.ecr.us-east-1.amazonaws.com/devops-tools:$(COMMIT_HASH); \
    )

# make part=patch branch=release_xyz release
release: git-status ## checkout main, merge in relesae branch, bump nad push
	$(info Merging branch $(branch) into $(MAIN_BRANCH) )
	git checkout $(MAIN_BRANCH)
	git pull --ff-only
	@make part=$(part) bump

get_commit: ## echo the commit hash
	@echo $(COMMIT_HASH)

get_version: ## echo the version
	@echo $(VERSION)

build_cache_clone: ## build cache_clone executable
	$(eval TD=$(shell mktemp -d))
	@echo $(TD)
	git clone git@github.com:imprivata-cloud/cache_clone.git $(TD)
	docker run --rm -v $(TD):/usr/src/myapp \
	-v $(PWD):/usr/src/myapp/build \
	--env GOOS=linux \
	--env GOARCH=amd64 \
	-w /usr/src/myapp golang:1.15.8 go build -v -o /usr/src/myapp/build/cache_clone
