# DevOps Assessment

This project contains three services:

* `quotes` which serves a random quote from `quotes/resources/quotes.json`
* `newsfeed` which aggregates several RSS feeds together
* `front-end` which calls the two previous services and displays the results.

1. Create an EC2 instance and install Docker & Terraform on it. - For developers.
-This is done by the use of IaC - Terraform

2. Create infrastructure as code using Terraform for the creation of the infrastructure 
Deploy the infrastructure using Terraform. 
## Initialize
Initialize the directory containing Terraform
Initialize configuration directory by downloading and install the providers defined in the configuration, which in this case is the aws provider.
$ terraform init

## Run the plan
After successful initialization, try to run “terraform plan” to see any changes that are required.
$ terraform plan

## Apply changes
Run “Terraform apply” to execute all terraform files
$ terraform apply
##

3. Create DockerFiles for the three services in Github
SSH to the EC2 instance and clone the repo with the apps from Github
Run the docker build from CLI
The Docker images will be pushed to an Amazon ECR repository


## Prerequisites

* Java
* [Leiningen](http://leiningen.org/) (can be installed using `brew install leiningen`)
* Docker
* Terraform

## Building & Running Services

The containers can be started up as below after pulling the images from Registry.

### Front-end app
$ docker pull aws_account_id.dkr.ecr.us-east-1.amazonaws.com/front-end:latest

$ docker build --tag front-end -f Dockerfile target

$ docker run --name front-end --env MY_ENV_VAR=some_value -p 3000:3000 -rm front-end

### Quote service
$ docker pull aws_account_id.dkr.ecr.us-east-1.amazonaws.com/quotes:latest

$ docker build --tag quotes -f Dockerfile target

$ docker run --name quotes --env MY_ENV_VAR=some_value -p 3010:3000 -rm quotes

### Newsfeed service
$ docker pull aws_account_id.dkr.ecr.us-east-1.amazonaws.com/newsfeed:latest

$ docker build --tag newsfeed -f Dockerfile target

$ docker run --name newsfeed --env MY_ENV_VAR=some_value -p 3020:3000 -rm newsfeed

### Check that containers are running

docker ps

### Stopping and Starting the containers
eg: 
docker container start newsfeed
docker container stop newsfeed
