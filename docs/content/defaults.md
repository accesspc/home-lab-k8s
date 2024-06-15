# Defaults

Minimal set of Kubernetes resources for the lab, including metrics-server, kube-state-metrics, dashboard and cert-manager.

Everything can be all installed by running a script:
```bash
./defaults/defaults.sh
```

### metrics-server

Scalable and efficient source of container resource metrics for Kubernetes built-in autoscaling pipelines [source](https://github.com/kubernetes-sigs/metrics-server).

Basically, allows you to run `kubectl top [node | pod]` and get basic CPU and RAM usage. In addition, this allows Kubernetes Dashboard to display the same information in it's web UI.

### kube-state-metrics

Add-on agent to generate and expose cluster-level metrics [source](https://github.com/kubernetes/kube-state-metrics).

There a whole bunch of documentation about this, but in a nutshell - it exposes metrics to Prometheus.

### dashboard

General-purpose web UI for Kubernetes clusters [source](https://github.com/kubernetes/dashboard).

It says it all.

### cert-manager

Certificate manager for Kubernetes. In this case - with Let's Encrypt issuer [source](https://cert-manager.io/docs/).
