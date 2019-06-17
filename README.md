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

## Sending logs from Azure Monitor to Logstash

## Installing Promitor and Prometheus

### Installing Helm
Create a file called `helm-rbac.yaml` with the following:

```
apiVersion: v1
kind: ServiceAccount
metadata:
  name: tiller
  namespace: kube-system
---
apiVersion: rbac.authorization.k8s.io/v1
kind: ClusterRoleBinding
metadata:
  name: tiller
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: ClusterRole
  name: cluster-admin
subjects:
  - kind: ServiceAccount
    name: tiller
    namespace: kube-system
```

Apply the file:
```
kubectl apply -f helm-rbac.yaml
```

Deploy Tiller:
```
helm init --service-account tiller
```

### Create Role Permissions

Create a Service Principal with Monitoring Reader role permissions, note the AppId and Password returned from it:

```
az ad sp create-for-rbac \
  --role="Monitoring Reader" \
  --scopes="/subscriptions/<sub-id>/resourceGroups/<rg-name>"
{
  "appId": <app-id>,
  "displayName": <display-name>,
  "name": <name>,
  "password": <app-key>,
  "tenant": <tenant-id>
}
```

### Generic Metrics Configuration for PostgreSQL and Redis

Select desired Metric and Aggregation types:
- [PostgreSQL](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers)
- [Redis Cache](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftcacheredis)

Create a file called `metrics-config.yaml`, add in your own values:

```metric-config.yaml
azureAuthentication:
  appId: <app-id>
  appKey: <app-key>
azureMetadata:
  tenantId: <tenant-id>
  subscriptionId: <sub-id>
  resourceGroupName: talend
metricDefaults:
  aggregation:
    interval: 00:05:00
  scraping:
    # every minute
    schedule: "0 * * ? * *"
metrics:
  - name: generic_redis_scraper
    description: "Generic scraper for Redis Cache"
    resourceType: Generic
    resourceUri: Microsoft.Cache/Redis/redis-cache-sample
    scraping:
      # scrape every 2 minutes
      schedule: "0 */2 * ? * *"
    azureMetricConfiguration:
      metricName: totalcommandsprocessed
      aggregation:
        type: Average
  - name: generic_postgresql_scraper
    description: "Generic scraper for PostgreSQL"
    resourceType: Generic
    resourceUri: Microsoft.DBforPostgreSQL/servers/postgresql-sample
    scraping:
      # scrape every 2 minutes
      schedule: "0 */2 * ? * *"
    azureMetricConfiguration:
      metricName: cpu_percent
      aggregation:
        type: Average
```

### Deploy Promitor:

```
helm repo add promitor https://promitor.azurecr.io/helm/v1/repo
helm install promitor/promitor-agent-scraper --name promitor-agent-scraper -f metrics-config.yaml
```

### Deploy Prometheus:

```
cat > promitor-scrape-config.yaml <<EOF
extraScrapeConfigs: |
  - job_name: promitor-agent-scraper
    metrics_path: /metrics
    static_configs:
      - targets:
        - promitor-agent-scraper.default.svc.cluster.local:8888
EOF
helm install stable/prometheus -f promitor-scrape-config.yaml
```

### Viewing Metrics

Run:
```
kubectl port-forward svc/promitor-agent-scraper 8080:8888
```

Navigate to the following URL in your browser:
```
http://localhost:8080/metrics
```

Where you should see output like the following:
```
# HELP generic_postgresql_scraper test
# TYPE generic_postgresql_scraper gauge
generic_postgresql_scraper{resource_uri="subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.DBforPostgreSQL/servers/postgresql-sample"} 3.975 1560790804135
# HELP promitor_ratelimit_arm Indication how many calls are still available before Azure Resource Manager is going to throttle us.
# TYPE promitor_ratelimit_arm gauge
promitor_ratelimit_arm{tenant_id=<tenant-id>,subscription_id=<sub-id>,app_id=<app-id>} 11982 1560790804101

```
