DOCKER_RUN = docker run --rm -u root -v ${PWD}:/foo -w="/foo"
PYBASH = $(DOCKER_RUN) python bash -c 
NODEBASH = $(DOCKER_RUN) node bash -c 
LOCAL_REGISTRY = localhost:5001

# Create cluster
.PHONY: create-cluster
create-cluster:
	./create-cluster.sh

# Install helm charts or add a new revision to the kind-e2e release if it already exists
.PHONY: helm-app
helm-app:
	helm upgrade --install app ./helm/app

# Deploy loki charts
.PHONY: helm-loki
helm-loki:
	helm repo add grafana https://grafana.github.io/helm-charts
	helm repo update

	# Build out the charts/ directory from the Chart.lock file.
	helm dependency build ./helm/loki

	helm upgrade --install loki-stack --namespace istio-system ./helm/loki

# Forward port 8080 on local host to ingress service
.PHONY: port-forward
port-forward:
	kubectl port-forward service/istio-ingressgateway 8080:http2 -n istio-system

# Delete kind cluster
.PHONY: clean-up
clean-up:
	kind delete cluster --name demo-cluster

# Build Django app Docker image
.PHONY: build-business-logic
build-business-logic:
	docker build -f business-logic/Dockerfile -t ${LOCAL_REGISTRY}/django-app business-logic/

# Build NodeJS (front-end) Docker image using local conf file
.PHONY: build-front-end
build-front-end:
	docker build -f front-end/Dockerfile -t ${LOCAL_REGISTRY}/nodejs-app front-end/

# Push Docker images to local registry
.PHONY: push
push:
	docker push ${LOCAL_REGISTRY}/django-app
	docker push ${LOCAL_REGISTRY}/nodejs-app

# Lints .py files in the repo
.PHONY: flake8
flake8:
	# The GitHub editor is 127 chars wide
	$(PYBASH) \
	"pip install -U pip && \
	pip install flake8 && \
	flake8 business-logic/ --extend-ignore=F405 --max-line-length=127"

# Lints yaml files in the repo
.PHONY: yamllint
yamllint:
	$(PYBASH) \
	"pip install -U pip && \
	pip install yamllint && \
	yamllint ."

# Auto-generate requirements.txt based on pyproject.toml
.PHONY: pip-compile
pip-compile:
	$(PYBASH) \
	"pip install -U pip && \
	pip install pip-tools && \
	pip-compile business-logic/pyproject.toml"

# Auto-generate package-lock.json based on package.json
.PHONY: npm-install
npm-install:
	$(NODEBASH) "cd front-end && npm install"
