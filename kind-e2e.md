<!-- markdownlint-disable-->

Self-contained CICD for testing purpose. Equivalent to sandbox environment.
   > Add Jenkins on k8s
      1/ Build Docker images
      2/ Deploys Helms charts
      3/ Runs smoke tests calling the API
      4/ runs k9s

> Add Let's encrypt?
> Use kubernetes-in-docker? https://www.conjur.org/blog/tutorial-spin-up-your-kubernetes-in-docker-cluster-and-they-will-come/

Security: use https://github.com/kubescape/kubescape for scanning running cluster? and Trivy for scanning manifest and docker images?
===============================

Plan > Code > Build > Testing > Release > Deploy: in financial-data-api
Operate > Monitor: in this project

> fill in the links I've left blank aka ()
> State questions to ask before designing a k8s cluster
> explain how to use the VS code extension for k8s to avoid using the terminal --> tuto here https://www.youtube.com/watch?v=Si6og3Wa2Hg
> https://ellin.com/2020/05/28/tools-every-kubernetes-developer-should-have/
> Explain why we need to use those tools: for example we need to persist logs and metrics. Need easy way to rollback deployment etc
> can also use kubectx and kubens for switching context and namespace faster (only if you are still using command line)
> use kube ps1 https://www.youtube.com/watch?v=xw3j4aNbHgQ
> live scan of k8s cluster with popeye  https://github.com/derailed/popeye

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
 > Liveness and Readiness Probes
 > use kubeconfig at $HOME/.kube/config  (dont forget to add current-context for defaulting to dev)
    > then $ kubectl config use-context prod-user@production
 > use multi cluster config for dev/prod segmentation  --> pros and cons https://vadimeisenberg.blogspot.com/2019/03/multicluster-pros-and-cons.html
 > use --authorization-mode=Node,RBAC,Webhook
 > use service account for grafana and prometheus? make sure you use the TokenRequest API, you shouldn't need to create a token yourself. explanation on why this is better here (https://github.com/kubernetes/enhancements/blob/master/keps/sig-auth/1205-bound-service-account-tokens/README.md)
    > audience bound
    > time bound
    > object bound
 
 > Add readiness and liveness probes in Django app
 > explain how istio ingress works
 > Add auto-doc for Helm?
 > Explain Helm: Package manager, templating, release management.
 > in practice business-logic/front-end/helm/jenkins should have their own repositories.
 > explain what each file is doing (below file tree)
 > port forwarding will stop if you change the cluster, you need to start forwarding again for the app to work.
 > Ingress isolation? maybe too much for this demo since there will be only 2 apps
 > use persistent volume and pvc? should add a note saying that for production use we shouldn't save data on the node itself.
    > or storage class? overkill for this demo
 > show IP tables and explain how kube-proxy works
 > We are installing Istio with the demo profile for testing purpose https://istio.io/latest/docs/setup/additional-setup/config-profiles/
 > how to access dashboard UI https://istio.io/latest/docs/setup/platform-setup/kind/#setup-dashboard-ui-for-kind
 > run `istioctl analyze` to check any issue with the configuration
 > need to add logs in front-end
 > If you see "no healthy upstream" while trying to access the web-app, wait for a couple of seconds until the app is up and running and that should work.
 > Create custom dashboard on Grafana
 > automatically open jaeger/grafana/website after cluster creation
 > Add a note on the fact that you need to add the "app" label to your deployments for the istio graphs to work
 > add istio diagram https://istio.io/latest/docs/ops/deployment/architecture/ 
   > explain what envoy and istiod are
> Explain what Promtail/Loki/Grafana are: https://www.infracloud.io/blogs/grafana-loki-log-monitoring-alerting/
=================================
Implementation:

memory of a pod can go above its limit, it will then be terminated. CPU can't go over limit --> need to show that in grafana

deployment: 2 replicas of each API

> by default istio instruments your services, but we want some fine grained tracing. Thats why we implement the Open Telemetry (OTel) 
====================================================
> CloudWatch Dashboards is not widely used in the industry [https://www.reddit.com/r/aws/comments/8qbtvf/why_not_cloudwatch_dashboards/]
	> interface is ugly
	> somebody talking about Grafana over Cloudwatch: "For me it’s multiple data sources on the same dashboard"
====================================================
TODO:

> deploy front-end (CSS and Node.Js):
   > need to render page based on port used for front-end

> Use helm
   > SKIP: install istio as a dependency in main helm chart?
      > Ingress issues, the ingress pod isn't exposing port 80 or 8080, why? service is pointing at http2 80 though
   
> prometheus /grafana
   > 1 dashboard with:
      > Pod CPU/Memory usage
      > Logs
      > why adding access logs?
      > filters:
         - namespace
         - date
      > Use Grafana Tempo with Jaeger backend, easier to correlate trace with the logs for better debugging.
      
> Jenkins
   > need to mount volume so that Jenkins has access to local files

====================================================
Ideas:
	1 - Implement Redis on the cluster for real time app
	2 - Canary deployment with Flagger? Or with Istio? cf https://geekflare.com/kubernetes-tools/
	3 - MinIO ? https://github.com/minio/operator/blob/master/README.md

Useful resources:

	[bregman-arie/devops-exercises](https://github.com/bregman-arie/devops-exercises)
    [Nice youtube series on Public Key Infrastructure](https://www.youtube.com/watch?v=LJDsdSh1CYM&list=PLIFyRwBY_4bTwRX__Zn4-letrtpSj1mzY&index=17) or (https://www.youtube.com/watch?v=q9vu6_2r0o4&list=PLDp2gaPHHZK-mnKi3Zy_-hRjqLHh5PaAv&index=1)
    [CNI specifications](https://github.com/containernetworking/cni/blob/main/SPEC.md#container-network-interface-cni-specification)
   [Kubernetes concepts](https://kubernetes.io/docs/concepts/overview/)
   [Network Policy Editor](https://editor.cilium.io/)
