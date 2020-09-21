A deployment of a Hello World app in Ruby.

This deployment dockerises the simple application and deploys to ECS on AWS.
The IAM Users in the AWS environment are already set, but the remaining infrastructure and deployment are within this repo.

## Getting Started

### Prerequisites

* `curl` is installed
* `jq` is installed
* `awscli` is installed
* `docker` and `docker-compose` are installed
* `make` is installed

Additionally, the following environment variables should be set:
* `AWS_ACCESS_KEY_ID`
* `AWS_SECRET_ACCESS_KEY`

### Basic commands and deploy

The default command `make` (or `make rebuild`) will:

* destroy the existing infrastructure and deploymenent
* build the container registry required to pull from for ECS
* push the dockerised image to the registry
* deploy the ECS service with pulled image from container registry

You can test the deployment by running `make test-deployment`. 
This simply curls the load balancer DNS and will return "Hello World". 
When rebuilding from scratch, you will want to give appropriate time between rebuild and test. 
The load balancer and target take some time to build!

When you are done and dusted, you can use `make clean-slate` to decommision the app.

If you would like to test the dockerised app locally, you can use `make docker-run-local`.

## Assumptions, Decisions and Drawbacks

* We want a solution that is scalable and where new applications may be added. There is generic infrastructure along with targeted infrastructure for the app (under `hello-world.tf`), broken down for readability and scalability
* We want a solution that can be pipelined. See the Makefile to see modularised actions that could be put into pipeline.
* Dockerising is necessary and preferable, to avoid a blow out in dependency
* ECS (Fargate) is the preferred solution ahead of plain EC2. It is managed, can easily pull from container registry and scales appropriately.
* The IAM of choice is Users/Service Accounts. A user can be given appropriate permissions and allows an easy, contained solution for pipelines. On the other hand, User access keys are difficult and dangerous to distribute.
* We want to destroy and rebuild base infrastructure when deploying an application. Usually, I would seperate the two, but this allows for an end to end solution that is idompotent. There are still commands for seperation, because the container registry having a pushed docker image is a prerequisite to the ECS tasks.
* `curl`, `make`, `awscli`, `docker`, `docker-compose` and `make` are standard for a cloud/devops engineer to have. I decided not to dockerise because I felt it was unnecessary, but there may be some reliance on versioning and also may require installation.
* This is not particularly Windows compatible
* Default location is Australia for data sovereignty.
* There is a full initialisation of terraform on each command for idempotency, despite initialisation not always being necessary.
* There is some hard coding of `AWS_ACCOUNT_ID`, in three places. Once replaced and with a User with appropriate permissions, this should work on any AWS account. 
