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
mkdir postgres-creds
echo -n '< REPLACE WITH POSTGRESQL USERNAME >' > postgres-creds/username-p.txt
echo -n '< REPLACE WITH POSTGRESQL PASS >' > postgres-creds/password-p.txt
echo -n '< REPLACE WITH POSTGRESQL HOSTNAME >' > postgres-creds/hostname-p.txt
```

Create secret with that folder

```bash
kubectl create secret generic postgresql-user-pass --from-file=postgres-creds
```

Leave no mark

```bash
rm -rf postgres-creds
```

Deploy the actual pod

```bash
kubectl apply -f sample-applications/postgresql-python-client/postgresql-python-deployment.yaml
```

See the progress of the deployment in the describe:
```
kubectl describe po -l app=postgresql-sample
  Type    Reason     Age   From                               Message
  ----    ------     ----  ----                               -------
  Normal  Scheduled  74s   default-scheduler                  Successfully assigned default/postgresql-sample-deployment-86b9d655f-mzqpj to aks-agentpool-31039371-1
  Normal  Pulling    72s   kubelet, aks-agentpool-31039371-1  pulling image "brusmx/postgresql-python-sample:1.0"
  Normal  Pulled     70s   kubelet, aks-agentpool-31039371-1  Successfully pulled image "brusmx/postgresql-python-sample:1.0"
  Normal  Created    69s   kubelet, aks-agentpool-31039371-1  Created container
  Normal  Started    69s   kubelet, aks-agentpool-31039371-1  Started container
```

And then after a few seconds you will see it consuming the database:
  
```
kubectl logs -l app=postgresql-sample

Obtained credentials .
Inserted 163 individuals
1516 rows. Sleeping for 300 seconds...

7 individuals deleted
1509 rows. Sleeping for 300 seconds...
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