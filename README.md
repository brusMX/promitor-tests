# Promitor Samples
A repo to obtain Azure Monitor metrics and consume them using Promitor.

## Requirements

In order to use the samples in this repo you must have:

- AKS cluster up and running K8s version > 1.12
- Promitor deployed
- Azure PostgreSQL deployed
- Azure Redis Cache Deployed
- Prometheus

## Run samples

There are 2 sample applications to start getting metrics into your cluster:

### PostgreSQL python sample application

To deploy the python app that consumes the PostgreSQL database you can run the following commands from the root of this directory.

```bash
kubectl apply -f sample-applications/postgresql-python-client/postgresql-python-deployment.yaml
```

### Redis ruby sample application

To deploy the ruby app that consumes Redis you can run the following commands from the root of this directory

```bash
kubectl apply -f sample-applications/redis-ruby-client/redis-ruby-deployment.yaml
```