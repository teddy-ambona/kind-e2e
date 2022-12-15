<!-- markdownlint-disable-->

Self-contained CICD for testing purpose. Equivalent to sandbox environment.
   > Add Jenkins on k8s
      1/ Build Docker images
      2/ Deploys Helms charts
      3/ Runs smoke tests calling the API
      4/ runs k9s

> Add Let's encrypt?
> Use kubernetes-in-docker? https://www.conjur.org/blog/tutorial-spin-up-your-kubernetes-in-docker-cluster-and-they-will-come/

Microservices: 1 front-end API + 1 business-logic-api + 1 DB POD (https://kubernetes.io/docs/tasks/run-application/run-replicated-stateful-application/)
Observability: Local Prometheus and Grafana
Tracing: openTelemetry and Jaeger
Security: use https://github.com/kubescape/kubescape for scanning running cluster? and Trivy for scanning manifest and docker images?
===============================

Plan > Code > Build > Testing > Release > Deploy: in financial-data-api
Operate > Monitor: in this project

> State questions to ask before designing a k8s cluster
> explain how to use the VS code extension for k8s to avoid using the terminal --> tuto here https://www.youtube.com/watch?v=Si6og3Wa2Hg
> or use K9S? https://k9scli.io/  BOTH should be used in parrallel https://ellin.com/2020/05/28/tools-every-kubernetes-developer-should-have/
> Explain why we need to use those tools: for example we need to persist logs and metrics. Need easy way to rollback deployment etc
> can also use kubectx and kubens for switching context and namespace faster (only if you are still using command line)
> use kube ps1 https://www.youtube.com/watch?v=xw3j4aNbHgQ
> live scan of k8s cluster with popeye  https://github.com/derailed/popeye
> explain verrsion skew

why do we use microk8s vs minikube: https://www.itprotoday.com/cloud-computing-and-edge-computing/lightweight-kubernetes-showdown-minikube-vs-k3s-vs-microk8s#:~:text=Minikube%20is%20the%20easiest%20overall,configure%20than%20the%20other%20distributions.
> use kubeadm https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/install-kubeadm/
> minikube is for single node cluster according to udemy course(need to double check this info)
> best practice is to not host workloads on the Master nodes
> "rolling update" is the default deployment strategy
> "k api-resources" to list resource short names
> use dev//prod namespaces and give read access only to some user (RBAC)
> apply LimitRange in dev and prod namespaces to set default pod resources
> use taint/toleration and nodeAffinity
> use DaemonSet for prometheus? (need to check documentation and best practices)
> use custom scheduling ? use scheduler profiles (Nice diagram here https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/) need to find a use case
> external etcd topology. ETCD elects a leader that processes the writes. Need 3 ETCD nodes mini as quorum of 2 is 2... Odd number of nodes is always preferred. Use 2 for the sake of the demo
> caution: anyone who is able to create a pod/deployment in a namespace can also access the secrets
    > Not checking-in secret object definition files to source code repositories.
    > encrypt ETCD secret data at rest
    > configure RBAC for secrets
    > secrets should be stored in 3rd party secret store provider like AWS/ Azure/ GCP...
    > use Helm Secrets?
 > use init containers?
 > Liveness and Readiness Probes
 > use kubeconfig at $HOME/.kube/config  (dont forget to add current-context for defaulting to dev)
    > then $ kubectl config use-context prod-user@production
 > use multi cluster config for dev/prod segmentation  --> pros and cons https://vadimeisenberg.blogspot.com/2019/03/multicluster-pros-and-cons.html
 > use --authorization-mode=Node,RBAC,Webhook
 > use service account for grafana and prometheus? make sure you use the TokenRequest API, you shouldn't need to create a token yourself. explanation on why this is better here (https://github.com/kubernetes/enhancements/blob/master/keps/sig-auth/1205-bound-service-account-tokens/README.md)
    > audience bound
    > time bound
    > object bound
 
 > Ingress isolation? maybe too much for this demo since there will be only 2 apps
 > use persistent volume and pvc? should add a note saying that for production use we shouldn't save data on the node itself.
    > or storage class? overkill for this demo
 > Networking: use CNI network plugin (Cilium CNI is the most popular but complex, if you want to easy way use Flannel)
    > not Docker network plugin for instance
    > The CNI should create a bridge network interface on each node
 > show IP tables and explain how kube-proxy works
 > ingress controller/resources (with Istio? Nginx could also be a solutionss)
 > Istio gateway
=================================
Implementation:

Simulate high workload and observe how it scales?

memory of a pod can go above its limit, it will then be terminated. CPU can't go over limit --> need to show that in grafana

deployment: 2 replicas of each APIcu
> use same Docker image, just use entrypoint and CMD for running different versions of it? or simply use different config file?
====================================================
> CloudWatch Dashboards is not widely used in the industry [https://www.reddit.com/r/aws/comments/8qbtvf/why_not_cloudwatch_dashboards/]
	> interface is ugly
	> somebody talking about Grafana over Cloudwatch: "For me it’s multiple data sources on the same dashboard"
====================================================
TODO:

> Setup kind cluster (DONE)
      > 2 master nodes + 2 worker nodes + 2 etcd

> deploy business-logic with Django
   > http:business-logic.demo-app/slow-endpoint  this endpoint should be calling nested functions and the DB
   > http:business-logic.demo-app/fast-endpoint this endpoint is not calling the DB and returns fast.
   > inject secrets as environment variables

> deploy DB

> how to only expose front-end with local DNS?
   > http://<some IP>/
   > using Load balancer external IP. Need to do it with Metallb https://kind.sigs.k8s.io/docs/user/loadbalancer/

> deploy front-end (CSS and Node.Js):
   > http:<some IP>/  which is the landing page of the website, it should have a slow page and fast loading page
   > http:<some IP>/slow-page
   > http:<some IP>/fast-page

> setup istio
   > https://istio.io/latest/docs/tasks/traffic-management/ingress/ingress-control/

> add instrumentation
   > use open-telemetry in python (https://github.com/open-telemetry/opentelemetry-python)
   > use opentelemetry with NodeJs

> prometheus /grafana

> Jenkins
   > need to mount volume so that Jenkins has access to local files

====================================================
Ideas:
	1 - Implement Redis on the cluster
	2 - Canary deployment with Flagger? Or with Istio? cf https://geekflare.com/kubernetes-tools/
	3 - MinIO ? https://github.com/minio/operator/blob/master/README.md

Useful resources:

	[bregman-arie/devops-exercises](https://github.com/bregman-arie/devops-exercises)
    [Nice youtube series on Public Key Infrastructure](https://www.youtube.com/watch?v=LJDsdSh1CYM&list=PLIFyRwBY_4bTwRX__Zn4-letrtpSj1mzY&index=17) or (https://www.youtube.com/watch?v=q9vu6_2r0o4&list=PLDp2gaPHHZK-mnKi3Zy_-hRjqLHh5PaAv&index=1)
    [CNI specifications](https://github.com/containernetworking/cni/blob/main/SPEC.md#container-network-interface-cni-specification)
   [Kubernetes concepts](https://kubernetes.io/docs/concepts/overview/)
   [Network Policy Editor](https://editor.cilium.io/)
