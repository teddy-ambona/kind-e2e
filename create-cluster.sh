#!/bin/sh
set -o errexit

# create registry container unless it already exists
reg_name='kind-registry'
reg_port='5001'
if [ "$(docker inspect -f '{{.State.Running}}' "${reg_name}" 2>/dev/null || true)" != 'true' ]; then
  docker run \
    -d --restart=always -p "127.0.0.1:${reg_port}:5000" --name "${reg_name}" \
    registry:2
fi

# create a cluster with the local registry enabled in containerd
kind create cluster --config=kind-cluster-config.yaml

# connect the registry to the cluster network if not already connected
if [ "$(docker inspect -f='{{json .NetworkSettings.Networks.kind}}' "${reg_name}")" = 'null' ]; then
  docker network connect "kind" "${reg_name}"
fi

# Document the local registry
# https://github.com/kubernetes/enhancements/tree/master/keps/sig-cluster-lifecycle/generic/1755-communicating-a-local-registry
cat <<EOF | kubectl apply -f -
apiVersion: v1
kind: ConfigMap
metadata:
  name: local-registry-hosting
  namespace: kube-public
data:
  localRegistryHosting.v1: |
    host: "localhost:${reg_port}"
    help: "https://kind.sigs.k8s.io/docs/user/local-registry/"
EOF

# Install Istio
istioctl install --set profile=demo -y

# Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies
# when you deploy your application later:
kubectl label namespace default istio-injection=enabled

kubectl apply -f helm/business-logic-deployment.yaml
kubectl apply -f helm/business-logic-service.yaml
kubectl apply -f helm/front-end-deployment.yaml
kubectl apply -f helm/front-end-service.yaml

# Setup kind dashboard
kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.7.0/aio/deploy/recommended.yaml

# Create a ServiceAccount and ClusterRoleBinding to provide admin access to the newly created cluster
kubectl create serviceaccount -n kubernetes-dashboard admin-user
kubectl create clusterrolebinding -n kubernetes-dashboard admin-user --clusterrole cluster-admin --serviceaccount=kubernetes-dashboard:admin-user

# To login to Dashboard, you need a Bearer Token. Use the following command to store the token in a variable.
token=$(kubectl -n kubernetes-dashboard create token admin-user)

# Display the token using the echo command and copy it to use for logging into Dashboard.
echo $token

# Associate this application with the Istio gateway:
kubectl apply -f helm/app_gateway.yaml

# Install add-ons. cf https://istio.io/latest/docs/ops/integrations/
# Grafana
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/grafana.yaml

# Prometheus
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/prometheus.yaml

# Jaeger
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/jaeger.yaml

# Kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/kiali.yaml

# Setup default tracing config
istioctl install -f helm/tracing.yaml -y

# kubectl port-forward service/istio-ingressgateway 8080:http2 -n istio-system
