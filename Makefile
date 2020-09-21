SHELL := /bin/bash -o pipefail
.SILENT:
.DEFAULT_GOAL := rebuild

# default variables
APP ?= hello-world
AWS_ACCOUNT_ID ?= 678727778487

# to mount to TF container
export AWS_DEFAULT_REGION=ap-southeast-2

TF_PREREQ_DIR = /opt/app/infrastructure
APP_DIR = /opt/app/applications/$(APP)
TF_INFRA_DIR = /opt/app/applications/terraform

TF_PREREQ = docker-compose run -w $(TF_PREREQ_DIR) terraform
TF_APP = docker-compose run -w $(TF_INFRA_DIR) terraform
IMAGE_BUILD = docker-compose build $(APP)
APP_RUN = docker-compose run -w $(APP_DIR) --service-ports $(APP)

rebuild: clean-slate registry-build docker-push-ecr infra-build

test-deployment:
	curl $$(aws elbv2 describe-load-balancers --names "application-lb" | jq -r ".LoadBalancers[0].DNSName") \

clean-slate: infra-clean registry-clean docker-clean

# Infrastructure
registry-plan: _init_registry
	$(TF_PREREQ) plan

registry-build: _init_registry
	$(TF_PREREQ) apply -auto-approve

registry-clean: _init_registry
	$(TF_PREREQ) destroy -auto-approve

# Helpers
.PHONY: _init_registry
_init_registry:
	$(TF_PREREQ) init


# App Infrastructure
infra-plan: _init_app
	$(TF_APP) plan

infra-build: _init_app
	$(TF_APP) apply -auto-approve

infra-clean: _init_app
	$(TF_APP) destroy -auto-approve

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


# DEBUGGING
# terraform infrastructure shell - intended for debugging
# refrain from using targeted applies
shell-terraform:
	docker-compose run -w $(TF_INFRA_DIR) --entrypoint sh terraform

# terraform container registry - intended for debugging
# refrain from using targeted applies
shell-skeleton-terraform:
	docker-compose run -w $(TF_PREREQ_DIR) --entrypoint sh terraform
