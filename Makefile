.PHONY: build-business-logic build-front-end flake8 yamllint pip-compile npm-install push

DOCKER_RUN = docker run --rm -u root -v ${PWD}:/foo -w="/foo"
PYBASH = $(DOCKER_RUN) python bash -c 
NODEBASH = $(DOCKER_RUN) node bash -c 
LOCAL_REGISTRY = localhost:5001

# Build Django app Docker image
build-business-logic:
	docker build -f business-logic/Dockerfile -t ${LOCAL_REGISTRY}/django-app business-logic/

# Build NodeJS (front-end) Docker image using local conf file
build-front-end:
	docker build -f front-end/Dockerfile -t ${LOCAL_REGISTRY}/nodejs-app front-end/

# Push Docker images to local registry
push:
	docker push ${LOCAL_REGISTRY}/django-app
	docker push ${LOCAL_REGISTRY}/nodejs-app

# Lints .py files in the repo
flake8:
	# The GitHub editor is 127 chars wide
	$(PYBASH) \
	"pip install -U pip && \
	pip install flake8 && \
	flake8 business-logic/ --extend-ignore=F405 --max-line-length=127"

# Lints yaml files in the repo
yamllint:
	$(PYBASH) \
	"pip install -U pip && \
	pip install yamllint && \
	yamllint ."

# Auto-generate requirements.txt based on pyproject.toml
pip-compile:
	$(PYBASH) \
	"pip install -U pip && \
	pip install pip-tools && \
	pip-compile business-logic/pyproject.toml"

# Auto-generate package-lock.json based on package.json
npm-install:
	$(NODEBASH) "cd front-end && npm install"
