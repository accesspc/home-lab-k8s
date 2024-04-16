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

## KeyCloak

Copy `system/keycloak/secret.yml.sample` to `system/keycloak/secret.yml` and set `KEYCLOAK_ADMIN_PASSWORD` to a base64 encoded string for your keycloak password.

```bash
kubectl apply -f system/keycloak
```

## How-To

### Base64 encode a password from command line

```bash
echo -n "password" | base64
```
