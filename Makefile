SHELL := /bin/bash -o pipefail
.SILENT:
# .DEFAULT_GOAL := start (TBD) 

TF_DIR = /opt/app/infrastructure

infra-build: 
	echo -e '\nApplying infrastructure...'
	# builds infrastructure required to deploy to 

infra-test:
	echo -e '\nConfirming ready to deploy...'
	# test infra 

shell-terraform:
	# terraform shell - intended for debugging
	docker-compose run  -w $(TF_DIR) --entrypoint sh terraform
