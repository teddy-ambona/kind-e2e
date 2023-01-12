<!-- markdownlint-disable-->

V2:
 use helm-file to manage chart releases across several namespaces https://github.com/helmfile/helmfile
 
=============================== 
Self-contained CICD for testing purpose. Equivalent to sandbox environment.
   > Add Jenkins on k8s
      1/ Build Docker images
      2/ Deploys Helms charts
      3/ Runs smoke tests calling the API
      4/ runs k9s

> Add Let's encrypt?

Security: use https://github.com/kubescape/kubescape for scanning running cluster? and Trivy for scanning manifest and docker images?
===============================

> fill in the links I've left blank aka ()
> State questions to ask before designing a k8s cluster
> explain how to use the VS code extension for k8s to avoid using the terminal --> tuto here https://www.youtube.com/watch?v=Si6og3Wa2Hg
> https://ellin.com/2020/05/28/tools-every-kubernetes-developer-should-have/
> Explain why we need to use those tools: for example we need to persist logs and metrics. Need easy way to rollback deployment etc
> can also use kubectx and kubens for switching context and namespace faster (only if you are still using command line)
> use kube ps1 https://www.youtube.com/watch?v=xw3j4aNbHgQ

why do we use microk8s vs minikube: https://www.itprotoday.com/cloud-computing-and-edge-computing/lightweight-kubernetes-showdown-minikube-vs-k3s-vs-microk8s#:~:text=Minikube%20is%20the%20easiest%20overall,configure%20than%20the%20other%20distributions.
> best practice is to not host workloads on the Master nodes
> "rolling update" is the default deployment strategy
> use dev//prod namespaces and give read access only to some user (RBAC)
> apply LimitRange in dev and prod namespaces to set default pod resources
> use custom scheduling ? use scheduler profiles (Nice diagram here https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/) need to find a use case
> external etcd topology. ETCD elects a leader that processes the writes. Need 3 ETCD nodes mini as quorum of 2 is 2... Odd number of nodes is always preferred. Use 2 for the sake of the demo
> caution: anyone who is able to create a pod/deployment in a namespace can also access the secrets
    > Not checking-in secret object definition files to source code repositories.
    > encrypt ETCD secret data at rest
    > configure RBAC for secrets
    > secrets should be stored in 3rd party secret store provider like AWS/ Azure/ GCP...
    > use Helm Secrets?
 > use kubeconfig at $HOME/.kube/config  (dont forget to add current-context for defaulting to dev)
    > then $ kubectl config use-context prod-user@production
 > use multi cluster config for dev/prod segmentation  --> pros and cons https://vadimeisenberg.blogspot.com/2019/03/multicluster-pros-and-cons.html
 > use --authorization-mode=Node,RBAC,Webhook
 > use service account for grafana and prometheus? make sure you use the TokenRequest API, you shouldn't need to create a token yourself. explanation on why this is better here (https://github.com/kubernetes/enhancements/blob/master/keps/sig-auth/1205-bound-service-account-tokens/README.md)
    > audience bound
    > time bound
    > object bound
 
 > Add readiness and liveness probes in Django app
 > Add auto-doc for Helm?
 > Explain Helm: Package manager, templating, release management.
 > explain what each file is doing (below file tree)
 > run `istioctl analyze` to check any issue with the configuration
 > need to add logs in front-end
=================================
Implementation:

Memory of a pod can go above its limit, it will then be terminated. CPU can't go over limit --> need to show that in grafana

deployment: 2 replicas of each API
====================================================
TODO:

> deploy front-end (CSS and Node.Js):
   > need to render page based on port used for front-end

> Need to install grafana after Loki and Jaeger so that data sources are valid
      > Loki is using LogQL --> https://grafana.com/docs/loki/latest/logql/
> Grafana data sources are defined in datasources.yaml in the configmap:
   > k8s how to append to file from configmap?
   > do we need to restart Grafana to pick up new config? Grafana API should allow doing that?

> Jenkins
   > need to mount volume so that Jenkins has access to local files

====================================================
Ideas:
	1 - Implement Redis on the cluster for real time app
	2 - Canary deployment with Flagger? Or with Istio? cf https://geekflare.com/kubernetes-tools/
	3 - MinIO ? https://github.com/minio/operator/blob/master/README.md

Useful resources:
    [Nice youtube series on Public Key Infrastructure](https://www.youtube.com/watch?v=LJDsdSh1CYM&list=PLIFyRwBY_4bTwRX__Zn4-letrtpSj1mzY&index=17) or (https://www.youtube.com/watch?v=q9vu6_2r0o4&list=PLDp2gaPHHZK-mnKi3Zy_-hRjqLHh5PaAv&index=1)
   [Kubernetes concepts](https://kubernetes.io/docs/concepts/overview/)
   [Network Policy Editor](https://editor.cilium.io/)
