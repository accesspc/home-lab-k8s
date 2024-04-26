# Prometheus

## Access

Once all recources are deployed, you can access Prometheus and Grafana on any of the cluster nodes' IP addresses. Pick one from the list:

```bash
kubectl get nodes -o wide
```

## Namespace

```bash
kubectl apply -f monitoring/namespace.yml
```

## Blackbox

```bash
kubectl apply -f monitoring/blackbox/
```

## SNMP

```bash
kubectl apply -f monitoring/snmp/
```

## Node Exporter

```bash
kubectl apply -f monitoring/node_exporter/
```

## Prometheus

1. Obtains Tailscale auth key from [tailscale admin](https://login.tailscale.com/admin/settings/keys) website
1. Base64 encode the key: `echo -n 'TAILSCALE_SECRET_KEY' | base64`
1. copy `monitoring/secret.yml.sample` file to `monitoring/secret.yml`
1. Put the base64 encoded key in `secret.yml` under `.data.TS_AUTHKEY`

```bash
kubectl apply -f monitoring/prometheus
```

* Prometheus:
  * https://<NODE_IP>:30090/
  * https://prometheus.k8s.reiciunas.dev:30030 (your FQDN defined in certificate.yml)

## Grafana

* [Grafana Dashboard Provisioning](https://grafana.com/docs/grafana/latest/administration/provisioning/#dashboards)
* [K8s-sidecar](https://github.com/kiwigrid/k8s-sidecar)

All Grafana Dashboards are automatically provisioned from this repo. The whole process is as follows:

1. Dashboard JSON files are stored in [./grafana/dashboards/](./monitoring/grafana/dashboards/)
1. `configMapGenerator` is used to generate ConfigMap for each dashboard, commands below to preview and apply changes
1. Grafana Deployment has a sidecar container based on `kiwigrid/k8s-sidecar` image, that picks ConfigMaps selected by labels and creates files on shared volume
1. Grafana Dashboard Provider, defined [here](./grafana/config/provider.yml), monitors the mounted shared volume and automatically applies ConfigMaps / dashboards changes, which are picked up by Grafana

```bash
# ConfigMap: preview
kubectl kustomize monitoring/grafana/config/
kubectl kustomize monitoring/grafana/dashboards/default/
kubectl kustomize monitoring/grafana/dashboards/kubernetes/

# Apply
kubectl apply -k monitoring/grafana/config/
kubectl apply -k monitoring/grafana/dashboards/default/
kubectl apply -k monitoring/grafana/dashboards/kubernetes/

kubectl apply -f monitoring/grafana
```

* Grafana:
  * https://<NODE_IP>:30030/
  * https://grafana.k8s.reiciunas.dev:30030 (your FQDN defined in certificate.yml)
