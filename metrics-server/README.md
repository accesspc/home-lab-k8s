# Kubernetes Metrics Server

This is a copy of components.yaml release v0.6.4 [GitHub](https://github.com/kubernetes-sigs/metrics-server/releases), with a minor change in Deployment -> Template -> Container['metrics-server'] -> args: `--kubelet-insecure-tls=true`

## Installation

Can be installed directly from a copy stored here locally:

```bash
kubectl apply -f metrics-server/components.yaml
```

or directly from github:

```bash
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
```

or via helm charts:

```bash
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
helm upgrade --install metrics-server metrics-server/metrics-server
```

The latter 2 options may not start up (did not for me) and metrics pod complained with logs:

```
E1218 20:28:29.600507       1 scraper.go:140] "Failed to scrape node" err="Get \"https://192.168.68.18:10250/metrics/resource\": x509: cannot validate certificate for 192.168.68.18 because it doesn't contain any IP SANs" node="k8s-worker2"
E1218 20:28:29.601432       1 scraper.go:140] "Failed to scrape node" err="Get \"https://192.168.68.16:10250/metrics/resource\": x509: cannot validate certificate for 192.168.68.16 because it doesn't contain any IP SANs" node="k8s-control"
E1218 20:28:29.609730       1 scraper.go:140] "Failed to scrape node" err="Get \"https://192.168.68.17:10250/metrics/resource\": x509: cannot validate certificate for 192.168.68.17 because it doesn't contain any IP SANs" node="k8s-worker1"
```
