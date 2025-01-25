# Prometheus

## Docker

[Collect Docker metrics with Prometheus](https://docs.docker.com/engine/daemon/prometheus/)

Update (create) `/etc/docker/daemon.json` file with contents:

```json
{
  "metrics-addr": "127.0.0.1:9323"
}
```

Replace `172.0.0.1` with `0.0.0.0` if you want metrics to be available outside of Docker host.
