.PHONY: clean-pyc clean-build docs clean
define BROWSER_PYSCRIPT
import os, webbrowser, sys
try:
	from urllib import pathname2url
except:
	from urllib.request import pathname2url

webbrowser.open("file://" + pathname2url(os.path.abspath(sys.argv[1])))
endef
export BROWSER_PYSCRIPT

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

BROWSER := python -c "$$BROWSER_PYSCRIPT"
DOCKER_LOCAL_NAME = tamock
DOCKER_REMOTE_ACC = replace_me
DOCKER_REMOTE_NAME = ${DOCKER_REMOTE_ACC}/${DOCKER_LOCAL_NAME}
DOCKER_TAG = latest

help:
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

githash:  ## create git hash for current repo HEAD
	[ ! -z "`git status`" ] && echo `git describe --match=DONOTMATCH --always --abbrev=40 --dirty` > .githash || echo 'Could not write githash.'

docker-build: githash  ## build docker container
	# Building image $(DOCKER_LOCAL_NAME):$(DOCKER_TAG)...
	docker build -t $(DOCKER_LOCAL_NAME):$(DOCKER_TAG) --label githash=$$(cat .githash) .

docker-push:  ## push docker container
	# Pushing image $(DOCKER_LOCAL_NAME):$(DOCKER_TAG) to $(DOCKER_REMOTE_NAME):$(DOCKER_TAG)...
	docker tag $(DOCKER_LOCAL_NAME):$(DOCKER_TAG) $(DOCKER_REMOTE_NAME):$(DOCKER_TAG)
	docker push $(DOCKER_REMOTE_NAME):$(DOCKER_TAG)

docker-pull:  ## pull docker container
	docker pull $(DOCKER_REMOTE_NAME):$(DOCKER_TAG)

docker: docker-build docker-push  ## build and push docker image
