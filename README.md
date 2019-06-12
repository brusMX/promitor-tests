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

Create secrets for postgreSQL credentials (remember this is not secure for prod environments):

```bash
# Create files to avoid escaping character
echo -n '< REPLACE WITH POSTGRESQL USERNAME >' > ./username-p.txt
echo -n '< REPLACE WITH POSTGRESQL PASS >' > ./password-p.txt
echo -n '< REPLACE WITH POSTGRESQL HOSTNAME >' > ./hostname-p.txt
kubectl create secret generic postgresql-user-pass --from-file=./username-p.txt --from-file=./password-p.txt --from-file=./hostname-p.txt
rm ./username-p.txt && rm ./password-p.txt
```

Deploy client:

```bash
kubectl apply -f sample-applications/postgresql-python-client/postgresql-python-deployment.yaml
```

### Redis ruby sample application

To deploy the ruby app that consumes Redis you can run the following commands from the root of this directory.

Create secrets for Redis credentials:

```bash
# Create files to avoid escaping character
echo -n '< REPLACE WITH REDIS USERNAME >' > ./username-r.txt
echo -n '< REPLACE WITH REDIS PASS >' > ./password-r.txt
echo -n '< REPLACE WITH POSTGRESQL HOSTNAME >' > ./hostname-r.txt
kubectl create secret generic redis-user-pass --from-file=./username-r.txt --from-file=./password-r.txt --from-file=./hostname-r.txt
rm ./username-r.txt && rm ./password-r.txt
```

```bash
kubectl apply -f sample-applications/redis-ruby-client/redis-ruby-deployment.yaml
```