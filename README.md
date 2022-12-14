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

In order to SSh into a node, we run:

```bash
docker exec -it <node-name> bash
```

## 4 - Project file structure

## 5 - TODO

## 6 - Useful resources

- [Certified Kubernetes Administrator (CKA) Course Notes](https://github.com/kodekloudhub/certified-kubernetes-administrator-course)
- [kind Official Documentation](https://kind.sigs.k8s.io/)
- [k9s](https://k9scli.io/)
