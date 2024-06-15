# Kube Prometheus Stack

[Official documentation](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack)

This is one of the ways to setup Prometheus and Grafana on your Kubernetes cluster.

Installs the kube-prometheus stack, a collection of Kubernetes manifests, Grafana dashboards, and Prometheus rules combined with documentation and scripts to provide easy to operate end-to-end Kubernetes cluster monitoring with Prometheus using the Prometheus Operator [source](https://github.com/prometheus-community/helm-charts/tree/main/charts/kube-prometheus-stack).

This thing installs a bunch of stuff, but not everything works on the local Lab without adjustments, thus there is the next option.

## Installation

The following instructions are for a local Kubernetes cluster setup made up of 3 virtual machines.

Add `prometheus-community` helm repo:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

### Deploy `kube-prometheus-stack` chart:

```bash
helm install \
 -n monitoring \
 --create-namespace \
 kps \
 prometheus-community/kube-prometheus-stack \
 --set grafana.service.type=NodePort \
 --ste prometheus.service.type=NodePort
```

or

```bash
helm install \
 -n monitoring \
 --create-namespace \
 kps \
 prometheus-community/kube-prometheus-stack \
 -f values.yaml
```

### Command arguments explained:

* `-n monitoring` - specify a namespace to deploy to
* `--create-namespace` - tells helm to auto-create a namespace if it doesn't exist
* `kps` - release name used within Kubernetes cluster
* `prometheus-community/kube-prometheus-stack` - chart name
* `--set *` - values to override during installation

Values can be set using `--set` arguments or using a `values.yaml` file and supplying it in `helm install` command with `-f values.yaml`.

#### `values.yaml` example

```yaml
---
grafana:
  service:
    type: NodePort
prometheus:
  service:
    type: NodePort
```

All configurable options with detailed comments available here:

```bash
helm show values prometheus-community/kube-prometheus-stack
```
