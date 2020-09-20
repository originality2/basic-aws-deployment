SHELL := /bin/bash -o pipefail
.SILENT:
# .DEFAULT_GOAL := start (TBD) 

# default variables
APP ?= hello-world
AWS_ACCOUNT_ID ?= 678727778487

# to mount to TF container
export AWS_DEFAULT_REGION=ap-southeast-2

TF_INFRA_DIR = /opt/app/infrastructure
APP_DIR = /opt/app/applications/$(APP)
TF_APP_DIR = $(APP_DIR)/terraform

TF_INFRA = docker-compose run -w $(TF_INFRA_DIR) terraform
TF_APP = docker-compose run -w $(TF_APP_DIR) terraform
IMAGE_BUILD = docker-compose build $(APP)
APP_RUN = docker-compose run -w $(APP_DIR) --service-ports $(APP)

build: clean-slate registry-build docker-push-ecr infra-build

# Infrastructure
registry-plan: _init_infra
	$(TF_INFRA) plan

registry-build: _init_infra
	echo -e '\nApplying infrastructure...'
	$(TF_INFRA) apply -auto-approve

registry-clean:
	$(TF_INFRA) destroy -auto-approve

# Helpers
.PHONY: _init_infra
_init_infra:
	$(TF_INFRA) init


# App Infrastructure
infra-plan: _init_app
	$(TF_APP) plan  -var-file="$(APP).tfvars"

infra-build: _init_app
	echo -e '\nApplying infrastructure...'
	$(TF_APP) apply -auto-approve -var-file="$(APP).tfvars"

infra-clean:
	$(TF_APP) destroy -auto-approve -var-file="$(APP).tfvars"

# Helpers
.PHONY: _init_app
_init_app:
	$(TF_APP) init

# Application
# builds and runs app image
docker-run-local: 
	$(IMAGE_BUILD)
	$(APP_RUN)

docker-push-ecr:
	aws ecr get-login-password --region $(AWS_DEFAULT_REGION) | docker login --username AWS --password-stdin $(AWS_ACCOUNT_ID).dkr.ecr.ap-southeast-2.amazonaws.com/docker-images
	$(IMAGE_BUILD)
	docker tag basic-aws-deployment_$(APP) $(AWS_ACCOUNT_ID).dkr.ecr.ap-southeast-2.amazonaws.com/docker-images
	docker push $(AWS_ACCOUNT_ID).dkr.ecr.ap-southeast-2.amazonaws.com/docker-images

docker-clean:
	docker-compose down --rmi all


shell-terraform:
	# terraform shell - intended for debugging
	docker-compose run -w $(TF_INFRA_DIR) --entrypoint sh terraform

clean-slate: registry-clean infra-clean docker-clean
