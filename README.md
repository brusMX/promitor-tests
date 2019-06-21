# Promitor Samples

A repo to ilustrate how to consume Azure Monitor metrics using Promitor. Based on Azure Redis and Azure PosgreSQL.

## Requirements

In order to use the samples in this repo you must have:

- [AKS cluster up and running K8s version > 1.12](https://docs.microsoft.com/en-us/azure/aks/tutorial-kubernetes-deploy-cluster)
- [Azure PostgreSQL deployed](https://docs.microsoft.com/en-us/azure/postgresql/quickstart-create-server-up-azure-cli)
- [Azure Redis Cache Deployed](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-python-get-started#create-an-azure-cache-for-redis-on-azure)

## Summary

  1. [Install Sample applications.](#run-samples-applications-to-start-consuming-redis-and-postgresql)
  2. [Install helm in your cluster.](#pre-req-installing-helm)
  3. [Deploy Promitor.](#deploy-promitor)
  4. [Deploy prometheus to scrape promitor.](#deploy-prometheus)
  5. [(Extra) Deploy grafana to see graphs of your info.](#deploy-grafana)

## Run samples applications to start consuming Redis and PostgreSQL

In this repo, we include a couple of sample applications to start generating metrics of the services.
Here are the instruction on [How to deploy redis and postgreSQL sample applications](sample-applications)

## Pre-req Installing Helm

Install [helm cli in your machine](https://helm.sh/docs/using_helm/#installing-helm), and then install helm on your cluster. 
To install it on your cluster here is the official AKS documentation on [how to install helm](https://docs.microsoft.com/en-us/azure/aks/kubernetes-helm). Or if TL;DR follow the next commands:

1. Deploy a Service Account for helm to have permissions to install apps on your cluster

  ```bash
  kubectl apply -f https://raw.githubusercontent.com/brusMX/promitor-tests/master/promitor/helm-install/helm-rbac.yaml
  ```

1. Install tiller in your cluster using your previous installed Helm CLI:

  ```bash
  helm init --service-account tiller
  ```

## Deploy promitor

### Obtain Monitoring Reader permissions

You can list your resource groups to confirm the name of your resource group that contains your Redis and PostgreSQL instances:

```bash
az group list -o table

...
Name                                               Location       Status
-------------------------------------------------  -------------  ---------
aksdebug-test                                      canadacentral  Succeeded
MC_aksdebug-test_aks-debug-test-001_canadacentral  canadacentral  Succeeded
```

In this sample, the resources are inside the resource group called `aksdebug-test-oh1`. Substitute the following command with your resource group name:

```bash
export RG= <<resource group name >>
```

To obtain the ID from the subscription currently being used in your azure terminal you can run the following command:

```bash
export SUB_ID=$(az account show -o tsv --query id)
```

Create a Service Principal with Monitoring Reader role permissions to this Resosurce group:

```bash
az ad sp create-for-rbac \
  --role="Monitoring Reader" \
  --scopes="/subscriptions/$SUB_ID/resourceGroups/$RG"
```

You will obtain the following service principal. You will need this information later:

```json
{
  "appId": <app-id>,
  "displayName": <display-name>,
  "name": <name>,
  "password": <app-key>,
  "tenant": <tenant-id>
}
```

### Generic Metrics Configuration for PostgreSQL and Redis

Download the sample file of `metrics-config.yaml` file, you can use `wget` or `curl -O`:

```bash
wget https://raw.githubusercontent.com/brusMX/promitor-tests/master/promitor/metrics-config.yaml
```

Make sure to replace the values of `<app-id>`, `<app-key>`, `<tenant-id>` and `<sub-id>` with your actual values. 
This config file retrieves the following 2 metrics `totalCommandsProcessed` in Redis and `cpu_percent` of PostgreSQL every 2 minutes.

Feel free to change these for your desired Metric and Aggregation types:

- [PostgreSQL](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers)
- [Redis Cache](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftcacheredis)

Also you can see more information in Promitor's official [docs](https://promitor.io/configuration/metrics/).
After your configuration file is done, you can pass it to helm to install promitor.

### Strongly typed scraper for Redis and PostgreSQL

PostgreSQL and Redis scrapers have been merged into Promitor master branch and will be available in v1.0.0 release in late June/early July.

Right now, you need to use the `tomkerkhove/promitor-agent-scraper-ci:pr596` CI image to get those two new scrappers.

You need to use the `--set` flag in the `helm install` command (below) in order to override the repository and tag to use:

```bash
--set image.repository='tomkerkhove/promitor-agent-scraper-ci' --set image.tag=pr596
```

Some sample metrics declaration files for each of these scraper are available in this repo:
- [Metrics declaration for Redis Cache](./promitor/metrics-config-redis.yaml)
- [Metrics declaration for PostgreSQL](./promitor/metrics-config-postresql.yaml)

### Helm install Promitor

```bash
helm repo add promitor https://promitor.azurecr.io/helm/v1/repo
helm install promitor/promitor-agent-scraper --name promitor-agent-scraper -f metrics-config.yaml
```

## Deploy Prometheus

Use a configuration file to indicate Prometheus to scrape data from Promitor.

```bash
helm install stable/prometheus -f https://raw.githubusercontent.com/brusMX/promitor-tests/master/promitor/promitor-scrape-config.yaml
```

### Viewing Metrics

See the promitor service in your local machine by forwarding the port:

```bash
kubectl port-forward svc/promitor-agent-scraper 8080:8888
```

Navigate to the following URL in your browser:

- <http://127.0.0.1:8080/metrics>

It can take some minutes, depending on the scraping schedule, but you should see the metrics like in the following sample output:

```bash
# HELP generic_postgresql_scraper test
# TYPE generic_postgresql_scraper gauge
generic_postgresql_scraper{resource_uri="subscriptions/<sub-id>/resourceGroups/<rg-name>/providers/Microsoft.DBforPostgreSQL/servers/postgresql-sample"} 3.975 1560790804135
# HELP promitor_ratelimit_arm Indication how many calls are still available before Azure Resource Manager is going to throttle us.
# TYPE promitor_ratelimit_arm gauge
promitor_ratelimit_arm{tenant_id=<tenant-id>,subscription_id=<sub-id>,app_id=<app-id>} 11982 1560790804101
```

If you are having issues seeing your metrics, you can see Promitor's logs with the following command:

```bash
kubectl logs -l app=promitor-agent-scraper
```

## Sending logs from Azure Monitor to Logstash
