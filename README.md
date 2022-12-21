# kind-e2e

Demo project with Kubernetes IN Docker local cluster

**IMPORTANT: This guide is intended for development, and not for a production deployment.**

## 1 - Target setup

- Local registry
- 3 master nodes
- 3 worker nodes
- jenkins:  1 master 3 slavess

## 2 - Prerequisites

- [Docker](https://docs.docker.com/get-docker/)(8.0 GB of memory and 4 CPUs)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)
- [istioctl](https://istio.io/latest/docs/setup/getting-started/#download)

## 3 - Quickstart

Create k8s cluster (each node is a Docker container) and local Docker registry.

```bash
./create-cluster.sh
```

In order to SSH into a node, we run:

```bash
docker exec -it <node-name> bash
```

Run these commands to access:

- Website: [http:localhost:8080/demo-app/](http:localhost:8080/demo-app/)
- Grafana: `istioctl dashboard grafana`
- Jaeger: `istioctl dashboard jaeger`
- Kiali: `istioctl dashboard kiali`

## 4 - Project file structure

## Istio as a service Mesh

## - Accessing the cluster

There are several ways to access the cluster from external. On Linux you can simply access the cluster using http://<LOAD-BALANCER-EXTERNAL-IP>:8080/demo-app. If you are on Windows you can use [Metallb](https://kind.sigs.k8s.io/docs/user/loadbalancer/) (baremetal loadbalancer project for kubernetes) that implements a k8s LoadBalancer without necessarily being in a hosted cloud. This works if you are on Windows but if you are running docker on MacOS like me you probably have noticed that Docker MacOS has some networking “deficiencies” and these can be overcome by installing a networking shim as explained in [this tutorial](https://www.thehumblelab.com/kind-and-metallb-on-mac/). However in this demo I used [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) which is a safer way to access the application (for testing purpose) in the cluster, and this will work of any platform :smiley:. You can then access the app using http://localhost:8080/demo-app/.

### Add workflow diagram with Kiali

kubectl port mapping --> istio ingress --> front-end service --> front-end pod

## Grafana dashboard

## Distributed tracing

Distributed tracing enables users to track a request through mesh that is distributed across multiple services. This allows a deeper understanding about request latency, serialization and parallelism via visualization.

Istio leverages Envoy’s distributed tracing feature to provide tracing integration out of the box. Specifically, Istio provides options to install various tracing backends and configure proxies to send trace spans to them automatically ([cf doc page](https://istio.io/latest/docs/tasks/observability/distributed-tracing/overview/))

Note that the default sampling rate is 1%, which means that 99% of the traces won't get reported. For testing purpose we want to see all traces so I've set the sampling rate to 100% in [tracing.yaml]()

### Meet Jaeger UI

Jaeger is a distributed tracing system released as open source by Uber Technologies. It is used for monitoring and troubleshooting microservices-based distributed systems, including:

- Distributed context propagation
- Distributed transaction monitoring
- Root cause analysis
- Service dependency analysis
- Performance / latency optimization

You can find details about how Jaeger works in the official [documentation](https://www.jaegertracing.io/docs/1.23/architecture/).

By default Istio provides service-to-service tracing without context propagation, so if service A calls B which calls C, you will get two traces A -> B and B -> C. For this demo we want something more practical such as instrumenting our application code rather than simply observing services. For this we make the use of OpenTelemetry (OTel) which is the [recommended instrumentation SDK](https://www.jaegertracing.io/docs/1.40/getting-started/#instrumentation). The OTel SDK implemented within our Django and NodeJS web-apps will allow us to create custom spans. A high-level diagram of how instrumentation has been instrumented in this demo is provided below:

<img src="./docs/diagrams/jaeger.drawio.png" width="850"/>

Note that the jaeger/all-in-one container is deployed through the [Istio add-on](https://istio.io/latest/docs/ops/integrations/jaeger/#installation). In case you are wondering why do we use a Zipkin exporter if we have a Jaeger backend, Jaeger backend has a [Zipkin compatible endpoint](https://www.jaegertracing.io/docs/1.40/getting-started/#all-in-one) listening on port 9411. We can then use `http://zipkin.istio-system.svc.cluster.local:9411/api/v2/spans` to send our spans to the Jaeger collector.

Since we are using Zipkin agent, [Istio documentation](https://istio.io/latest/docs/tasks/observability/distributed-tracing/overview/) states that the B3 multi-header format should be forwarded. [B3](https://github.com/openzipkin/b3-propagation#multiple-headers) specification elaborates identifiers used to place an operation in a trace tree. For instance, the sampling decision will be made in-process and won't be collected and reported to the tracing system.

Although Istio proxies can automatically send spans, extra information is needed to join those spans into a single trace. Applications must propagate this information in HTTP headers, so that when proxies send spans, the backend can join them together into a single trace.

To do this, the front-end must collect headers from each incoming request and forward the headers to all outgoing requests triggered by that incoming request. This has been done [here]() in our NodeJS application.

## Kiali

## Clean up

```
# Delete kind cluster
kind delete cluster --name demo-cluster

# Delete kind Docker registry
docker kill kind-registry
```

## 5 - TODO


## Useful commands

Restart pods (after config change for example):

```bash
kubectl rollout restart deployment <deployment_name> -n <namespace>
```

## Tools that make your life easier

[k9s](https://k9scli.io/): For quick k8s cluster interaction (you can stop typing the time-consuming kubectl commands :smiley:)

<img src="./docs/img/k9s.png" width="850"/>

## 6 - Useful resources

- [Certified Kubernetes Administrator (CKA) Course Notes](https://github.com/kodekloudhub/certified-kubernetes-administrator-course)
- [kind Official Documentation](https://kind.sigs.k8s.io/)

- [popeye](https://github.com/derailed/popeye)
