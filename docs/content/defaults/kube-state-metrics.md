# Kube State Metrics (STM)

[Official documentation](https://github.com/kubernetes/kube-state-metrics)

## Installation

Setup Helm charts:

```bash
helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm repo update
```

```bash
helm install -n kube-system kube-state-metrics prometheus-community/kube-state-metrics
```
