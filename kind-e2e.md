<!-- markdownlint-disable-->

> fill in the links I've left blank aka ()
> State questions to ask before designing a k8s cluster

> best practice is to not host workloads on the Master nodes
> "rolling update" is the default deployment strategy

> apply LimitRange in dev and prod namespaces to set default pod resources
> use custom scheduling ? use scheduler profiles (Nice diagram here https://kubernetes.io/docs/concepts/scheduling-eviction/scheduling-framework/) need to find a use case
> external etcd topology. ETCD elects a leader that processes the writes. Need 3 ETCD nodes mini as quorum of 2 is 2... Odd number of nodes is always preferred. Use 2 for the sake of the demo
 
 > Loki is using LogQL --> https://grafana.com/docs/loki/latest/logql/
 > Add readiness and liveness probes in Django app
 > Add auto-doc for Helm?
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

> Need to configure exemplar in django-prometheus:
   > overriden PrometheusAfterMiddlewareWithExemplar and added exemplar arg in .inc()
   > Can't see exemplar with:
      curl --header "Accept: application/openmetrics-text" http://business-logic.default.svc:8000/metrics
   > why?
   > need to debug curl with a sample local web-app with breakpoint in prometheus_client.exposition
      > it works, so why django doesn't work?
   > need to run local django
     'application/openmetrics-text; version=0.0.1; charset=utf-8'

> In Grafana, we should use time-series type of panel to see exemplar by hovering on data point
> Exemplars not supported in multi-process mode? (ie gunicorn)
> need to add --enable-feature=exemplar-storage to argument of prom docker image
   (cf https://github.com/prometheus/prometheus/blob/fa6e05903fd3ce52e374a6e1bf4eb98c9f1f45a7/docs/feature_flags.md#exemplars-storage

Need to configure exemplars in prometheus data source:
https://vbehar.medium.com/using-prometheus-exemplars-to-jump-from-metrics-to-traces-in-grafana-249e721d4192
   > how to add trace ID exemplar in django-prometheus metrics?
   > example overwritting all metrics here: https://github.com/marcel-dempers/docker-development-youtube-series/blob/master/monitoring/prometheus/python-application/src/server.py
   > explanation on each metric type here: https://linuxhint.com/monitor-python-applications-prometheus/
   > "You can only have one exemplar per metric, this means when another request fits into that bucket, then the values will be overwritten."

Other tutorial
https://grafana.com/blog/2020/11/09/trace-discovery-in-grafana-tempo-using-prometheus-exemplars-loki-2.0-queries-and-more/

Only need metrics to trace (exemplars) and metrics to logs
----------------

> Jenkins
   > need to mount volume so that Jenkins has access to local files

====================================================
Ideas:
	1 - Implement Redis on the cluster for real time app
	2 - Canary deployment with Flagger? Or with Istio? cf https://geekflare.com/kubernetes-tools/


Useful resources:
    [Nice youtube series on Public Key Infrastructure](https://www.youtube.com/watch?v=LJDsdSh1CYM&list=PLIFyRwBY_4bTwRX__Zn4-letrtpSj1mzY&index=17) or (https://www.youtube.com/watch?v=q9vu6_2r0o4&list=PLDp2gaPHHZK-mnKi3Zy_-hRjqLHh5PaAv&index=1)
   [Kubernetes concepts](https://kubernetes.io/docs/concepts/overview/)
   [Network Policy Editor](https://editor.cilium.io/)
