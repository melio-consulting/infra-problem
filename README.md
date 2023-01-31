# DevOps Assessment

This project contains three services:

* `quotes` which serves a random quote from `quotes/resources/quotes.json`
* `newsfeed` which aggregates several RSS feeds together
* `front-end` which calls the two previous services and displays the results.

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
