# System wide services

## Namespace

```bash
kubectl apply -f system/namespace.yml
```

## Postgres

Copy `system/postgres/secret.yml.sample` to `system/postgres/secret.yml` and set `POSTGRES_PASSWORD` to a base64 encoded string for your postgres password.

```bash
kubectl apply -f system/postgres
```
