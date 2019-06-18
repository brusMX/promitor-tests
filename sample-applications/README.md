# Sample apps for Redis and PostgreSQL

There are 2 sample applications to start getting metrics into your cluster, `postgresql-python-sample` and `redis-ruby-sample`.

### Requirements

1. AKS cluster up and running.
2. Azure Redis credentials.
3. Azure PostgreSQL credentials.
4. Terminal connected with Kubectl to your cluster.

### Easy steps - Summary

1. Create two folders: `postgres-creds` and `redis-creds`. Paste your credentials in them like the instructions suggest.
2. Create a kubernetes secret.
3. Deploy both services: `postgresql-python-deployment.yaml` and `redis-ruby-deployment.yaml`
4. Verify they are both up and running.

Here are the details on how to deploy each application.

### Deploy PostgreSQL python sample application

To deploy the python app that consumes the PostgreSQL database you can run the following commands from the root of this directory.

#### Put credentials in a folder

Create secrets for postgreSQL credentials (remember this is not secure for prod environments):

```bash
# Create files to avoid escaping character
mkdir postgres-creds
echo -n '< REPLACE WITH POSTGRESQL USERNAME >' > postgres-creds/username-p.txt
echo -n '< REPLACE WITH POSTGRESQL PASS >' > postgres-creds/password-p.txt
echo -n '< REPLACE WITH POSTGRESQL HOSTNAME >' > postgres-creds/hostname-p.txt
```

#### Create k8s secret with that folder

```bash
kubectl create secret generic postgresql-user-pass --from-file=postgres-creds
```

The credentials are now stored in the cluster. You can delete them from your computer

```bash
rm -rf postgres-creds
```

#### Deploy the application to your cluster

```bash
kubectl apply -f sample-applications/postgresql-python-client/postgresql-python-deployment.yaml
```

#### Verify the installation

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
  
```bash
kubectl logs -l app=postgresql-sample

Obtained credentials .
Inserted 163 individuals
1516 rows. Sleeping for 300 seconds...

7 individuals deleted
1509 rows. Sleeping for 300 seconds...
```

### Redis ruby sample application

To deploy the ruby app that consumes Redis you can run the following commands from the root of this directory.

#### Put credentials in a folder

Create secrets for Redis credentials:

```bash
mkdir redis-creds
# Create files to avoid escaping character
echo -n '< REPLACE WITH REDIS PASS >' > redis-creds/password-r.txt
echo -n '< REPLACE WITH POSTGRESQL HOSTNAME >' > redis-creds/hostname-r.txt
```

#### Create a k8s secret with that folder

```bash
kubectl create secret generic redis-creds --from-file=redis-creds
```

And remove the folder from your filesystem:

```bash
rm -rf redis-creds
```

#### Deploy your redis application

```bash
kubectl apply -f sample-applications/redis-ruby-client/redis-ruby-deployment.yaml
```

#### Verify the deployment

Wait for your pod to be up and running:

```bash
kubectl get pods -l app=redis-sample
---
NAME                                       READY   STATUS    RESTARTS   AGE
redis-sample-deployment-7f95f4b86c-ttj6b   1/1     Running   0          6m32s
```

You can use forward your local port 9090 to connect to that service.

```bash
kubectl port-forward redis-sample-deployment-7f95f4b86c-ttj6b 9090:3000
```

Visit [127.0.0.1:9090](127.0.0.1:9090) where you willl see a list of articles. Create a few and that will upload them to Redis.
