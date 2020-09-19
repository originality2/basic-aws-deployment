SHELL := /bin/bash -o pipefail
.SILENT:
# .DEFAULT_GOAL := start (TBD) 

# default variables
KEY_PAIR ?= EntryKey

export AWS_DEFAULT_REGION=ap-southeast-2

TF_DIR = /opt/app/infrastructure
APP_DIR = /opt/app/applications/hello-world

TF = docker-compose run -w $(TF_DIR) terraform
IMAGE_BUILD = docker-compose build hello-world
APP_RUN = docker-compose run -w $(APP_DIR) --service-ports hello-world

# Infrastructure
infra-plan: _init
	$(TF) plan -var-file="app_config.tfvars"

infra-build: _init
	echo -e '\nApplying infrastructure...'
	$(TF) apply -auto-approve -var-file="app_config.tfvars"

infra-test:
	echo -e '\nConfirming ready to deploy...'
	# test infra 

# Helpers
.PHONY: _init
_init:
	$(TF) init

# Application
docker-build: 
	$(IMAGE_BUILD)
	$(APP_RUN)

shell-terraform:
	# terraform shell - intended for debugging
	docker-compose run -w $(TF_DIR) --entrypoint sh terraform

shell-aws:
	docker-compose run -w $(AWS_DIR) --entrypoint sh aws

