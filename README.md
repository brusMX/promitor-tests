# Promitor Samples

A repo to ilustrate how to consume Azure Monitor metrics using Promitor. Based on Azure Redis and Azure PosgreSQL.

## Requirements

In order to use the samples in this repo you must have:

- AKS cluster up and running K8s version > 1.12
- Promitor deployed
- Azure PostgreSQL deployed
- Azure Redis Cache Deployed
- Prometheus

## Run samples applications to start consuming Redis and PostgreSQL

In this repo, we include a couple of sample applications to start generating metrics of the services.
Here are the instruction on [How to deploy redis and postgreSQL sample applications](sample-applications)

## Sending logs from Azure Monitor to Logstash

## Installing Promitor and Prometheus

### Installing Helm

Create a file called `helm-rbac.yaml` with the following:

```bash
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
