SHELL := /bin/bash -o pipefail
.SILENT:
# .DEFAULT_GOAL := start (TBD) 

# default variables
KEY_PAIR ?= EntryKey

export AWS_DEFAULT_REGION=ap-southeast-2

TF_DIR = /opt/app/infrastructure
AWS_DIR = /opt/app

TF = docker-compose run -w $(TF_DIR) terraform
AWS = docker-compose run -w $(AWS_DIR) aws

infra-plan: _init
	$(TF) plan

infra-build: _init
	echo -e '\nApplying infrastructure...'
	$(TF) apply -auto-approve

infra-test:
	echo -e '\nConfirming ready to deploy...'
	# test infra 

key-pair:
	$(AWS) ec2 create-key-pair --key-name $(KEY_PAIR) --output text > aws/.secrets/ssh.pem

destroy-key-pair:
	docker-compose run aws ec2 delete-key-pair --key-name $(KEY_PAIR)
	docker-compose run --entrypoint="rm -f .aws/.secrets/ssh.pem" aws

shell-terraform:
	# terraform shell - intended for debugging
	docker-compose run -w $(TF_DIR) --entrypoint sh terraform

shell-aws:
	docker-compose run -w $(AWS_DIR) --entrypoint sh aws

# Helpers
.PHONY: _init
_init:
	$(TF) init
