# kind-e2e

Demo project with Kubernetes IN Docker local cluster

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

## Jaeger UI

## Kiali

## Clean up

```
# Delete kind cluster
kind delete cluster --name demo-cluster

# Delete kind Docker registry
docker kill kind-registry
```

## 5 - TODO



## 6 - Useful resources

- [Certified Kubernetes Administrator (CKA) Course Notes](https://github.com/kodekloudhub/certified-kubernetes-administrator-course)
- [kind Official Documentation](https://kind.sigs.k8s.io/)
- [k9s](https://k9scli.io/)
- [popeye](https://github.com/derailed/popeye)
