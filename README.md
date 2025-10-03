# Keycloak Playground

This repository is the place where I condense all the exploration of Red Hat Build of Keycloak and the upstream version.

## Getting Started

There are two options:

1. **Helm template + oc apply** - Use `helm template` to generate manifests and then apply them with `oc apply`.
2. **GitOps with ArgoCD** - Use ArgoCD to deploy the application.

### Helm template

```bash
helm template keycloak-chart --set global.clusterDomain=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') | oc apply -f -
```

### GitOps with ArgoCD

```bash
cat application-keycloak.yaml | \
  CLUSTER_DOMAIN=$(oc get dns.config/cluster -o jsonpath='{.spec.baseDomain}') \
  envsubst | oc apply -f -
```

## Access the Keycloak instance

Keycloak will have two main endpoints to check:

- Keycloak Admin Console: 
  - Url: `oc get route -n keycloak -l 'app=keycloak' -o go-template='https://{{(index .items 0).spec.host}}'`.
  - Username: `admin`.
  - Password: `admin`.
- Keycloak Example Realm: 
  - Url: `oc get route -n keycloak -l 'app=keycloak' -o go-template='https://{{(index .items 0).spec.host}}/realms/example-realm/account'`.
  - Username: `john-doe`.
  - Password: `john-doe`.






## Features explored


### 1. PostgreSQL SSL

PostgreSQL SSL is enabled by default based on the `values.yaml` file using the `postgresql.ssl` flag. Here you can see how to test that the PostgreSQL SSL is working using the `psql` command from the PostgreSQL container.

```bash
# No SSL
oc exec -n keycloak -it postgresql-db-0 -- bash -c 'psql "host=postgresql-db dbname=keycloak user=testuser password=testpassword sslmode=disable"'
psql (17.6 (Debian 17.6-2.pgdg13+1))
Type "help" for help.

# SSL Enforced
oc exec -n keycloak -it postgresql-db-0 -- bash -c 'psql "host=postgresql-db dbname=keycloak user=testuser password=testpassword sslmode=require"'
psql (17.6 (Debian 17.6-2.pgdg13+1))
SSL connection (protocol: TLSv1.3, cipher: TLS_AES_256_GCM_SHA384, compression: off, ALPN: postgresql)
Type "help" for help.
```

In this [link](https://www.postgresql.org/docs/17/libpq-envars.html) you can find more information about the PostgreSQL SSL connection parameters.

To check which configuration options to configure on the PostgreSQL server side, you can check the example configuration file that is present inside the PostgreSQL container:

```bash
oc exec -n keycloak -it postgresql-db-0 -- cat /usr/share/postgresql/postgresql.conf.sample
```

### 2. Management Interface

The management interface allows accessing management endpoints via a different HTTP server than the primary one. It provides the possibility to hide endpoints like /metrics or /health from the outside world and, therefore, hardens the security.

To access the management interface, you can `oc port-forward` to the management interface port:

```bash
oc port-forward svc/keycloak-service 9000:9000 -n keycloak
```

Then, you can access the management interface at `https://localhost:9000`:

* `curl -k https://localhost:9000/health`
* `curl -k https://localhost:9000/metrics`


### 3. Grafana Dashboards

The product does not come with any Grafana Dashboards. However, you can use the ones provided upstream in the `conf/grafana` folder. If you want to update them, you can check in their GitHub repository [here](https://github.com/keycloak/keycloak-grafana-dashboard).








## Useful links

- [Red Hat build of Keycloak Documentation](https://docs.redhat.com/en/documentation/red_hat_build_of_keycloak/26.2).
- [Red Hat build of Keycloak Component Details](https://access.redhat.com/articles/7027683).
- [Red Hat build of Keycloak Supported Configurations](https://access.redhat.com/articles/7033107).


## Great Workshops

- [Angel Ollé's Keycloak workshop](https://olleb.com/rhbk-workshop/).