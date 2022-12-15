.PHONY: build-business-logic build-front-end flake8 yamllint pip-compile

DRUN = docker run --rm
DBASH = $(DRUN) -u root -v ${PWD}:/foo -w="/foo" python bash -c 

# Build Django app Docker image
build-business-logic:
	docker build -f business-logic/Dockerfile -t django-app .

# Build NodeJS (front-end) Docker image using local conf file
build-front-end:
	docker build -f front-end/Dockerfile -t nodejs-app .

# Lints .py files in the repo
flake8:
	# The GitHub editor is 127 chars wide
	$(DBASH) \
	"pip install -U pip && \
	pip install flake8 && \
	flake8 business-logic/ --extend-ignore=F405 --max-line-length=127"

# Lints yaml files in the repo
yamllint:
	$(DBASH) \
	"pip install -U pip && \
	pip install yamllint && \
	yamllint ."

# Auto-generate requirements.txt based on pyproject.toml
pip-compile:
	$(DBASH) \
	"pip install -U pip && \
	pip install pip-tools && \
	pip-compile business-logic/pyproject.toml"
