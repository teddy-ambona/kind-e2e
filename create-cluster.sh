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

# Install Istio and setup default tracing config
istioctl install --set profile=demo -f tracing.yaml -y

# Add a namespace label to instruct Istio to automatically inject Envoy sidecar proxies
# when you deploy your application later:
kubectl label namespace default istio-injection=enabled

# Install add-ons. cf https://istio.io/latest/docs/ops/integrations/
# Grafana
kubectl apply -f grafana.yaml

# Update root url to make app accessible through Virtual Service and port forwarding
# https://stackoverflow.com/questions/67187642/how-to-use-virtualservice-to-expose-dashboards-like-grafana-prometheus-and-kiali
kubectl set env deployment grafana -n istio-system \
GF_SERVER_ROOT_URL='http://localhost:3000/grafana/' \
GF_SERVER_DOMAIN=localhost \
GF_SERVER_SERVE_FROM_SUB_PATH='true'

# Prometheus
kubectl apply -f prometheus.yaml

# Jaeger
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/jaeger.yaml

# Kiali
kubectl apply -f https://raw.githubusercontent.com/istio/istio/release-1.16/samples/addons/kiali.yaml

# Loki-stack
make helm-loki

# kubectl port-forward service/istio-ingressgateway 8080:http2 -n istio-system
