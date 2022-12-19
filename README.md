# kind-e2e

Demo project with Kubernetes IN Docker local cluster

## 1 - Target setup

- Local registry
- 3 master nodes
- 3 worker nodes
- jenkins:  1 master 3 slavess

## 2 - Prerequisites

- [Docker](https://docs.docker.com/get-docker/)
- [Kind](https://kind.sigs.k8s.io/docs/user/quick-start/#installation)

## 3 - Quickstart

Create k8s cluster (each node is a Docker container) and local Docker registry.

```bash
./create-cluster.sh
```

In order to SSH into a node, we run:

```bash
docker exec -it <node-name> bash
```

## 4 - Project file structure


## - Accessing the cluster

To access the cluster from external we will need Metallb. Metallb is a baremetal loadbalancer project for kubernetes that implements a k8s LoadBalancer without necessarily being in a hosted cloud. . Don't forget to check out the [load balancer section](https://kind.sigs.k8s.io/docs/user/loadbalancer/) in the kind documentation

Running docker on MacOS has some “deficiencies” that can be overcome by installing a networking shim as explained in [this tutorial](https://www.thehumblelab.com/kind-and-metallb-on-mac/). In this demo (since I am writing this from a MacBook Pro) I used [port forwarding](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/) to access the application in the cluster. you can then access the app using http://localhost:8000, and if you are running this on windows you should also be able to reach the load balancer at http://<LOAD-BALANCER-EXTERNAL-IP>:8000.

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
