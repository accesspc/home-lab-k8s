# Home Lab: K8s

A little how to what this is and what it's used for. The whole point for this K8s lab setup is to learn and test the ways of Kubernetes. In order to do so, I've built a 3 server node Kubernetes cluster and strapped on some monitoring. I'm sure there are probably better ways of doing things, like Helm and etc., but bare in mind this is a local lab without Cloud as a backend, so not everything works out-of-the-box.

With all that in mind, here are the steps and services that are deployed, and the prefered order of things.

## Tools

### Debug / BusyBox

K8s SwissKnife / debug box. This command runs it in `monitoring` namespace, interactive shell and deletes itself after exit to leave it all clean.

```bash
kubectl -n monitoring run -i --rm --tty busybox --image=busybox --restart=Never -- sh
```

### K9s - Kubernetes CLI

[Official documentation](https://k9scli.io/)

Quick install:

```bash
brew install derailed/k9s/k9s
```

### Krr

[Official documentation](https://github.com/robusta-dev/krr)

Prometheus-based Kubernetes Resource Recommendations

Quick install:

```bash
brew tap robusta-dev/homebrew-krr
brew install krr
```

Run:

```bash
krr simple -p https://prometheus.k8s.reiciunas.dev:30090
```
