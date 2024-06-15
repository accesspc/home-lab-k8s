# Cert Manager

[Official documentation](https://cert-manager.io/docs/)

## Installation

Setup Helm charts:

```bash
helm repo add jetstack https://charts.jetstack.io
helm repo update
```

Install with CRDs for easier management and updates:

```bash
helm upgrade --install \
  cert-manager jetstack/cert-manager \
  --namespace cert-manager \
  --create-namespace \
  --set installCRDs=true
```

## Setup ClusterIssuer with DNS

### AWS Route53

Detailed documentation and all the options available [here](https://cert-manager.io/docs/configuration/acme/dns01/route53/).

Before deploying this, need to copy the following files from samples and apply appropriate settings:

* `clusterissuer.yml`:
    * .spec.acme.email
    * .spec.acme.solvers[0].selector.dnsZones[0]
    * .spec.acme.solvers[0].dns01.route53.accessKeyIDSecretRef
    * .spec.acme.solvers[0].dns01.route53.hostedZoneID
    * .spec.acme.solvers[0].dns01.route53.region
    * .spec.acme.solvers[0].dns01.route53.secretAccessKeySecretRef
* `secret.yml`:
    * .data.ACCESS_KEY
    * .data.SECRET_ACCESS_KEY

### Cloudflare

Detailed documentation and all the options available [here](https://cert-manager.io/docs/configuration/acme/dns01/cloudflare/).

Before deploying this, need to copy the following files from samples and apply appropriate settings:

* `clusterissuer.yml`:
    * .spec.acme.email
    * .spec.acme.solvers[0].selector.dnsZones[0]
    * .spec.acme.solvers[0].dns01.cloudflare.apiTokenSecretRef
* `secret.yml`:
    * .data.API_TOKEN

## Apply changes

Once that's prepared, apply the changes:

```bash
kubectl apply -f cert-manager/
```

This creates a Cluster wide Issuer, that can be used across all the namespaces to issue the certificates.
