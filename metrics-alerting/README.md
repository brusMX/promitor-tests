# A word about interesting metrics

This document intends to do a brief analysis and give an opinion on how these metrics can be used for SRE teams to have insights on their monitored systems.


## Services in this sample

For this repository we will focus on 3 popular services:

- [A word about interesting metrics](#A-word-about-interesting-metrics)
  - [Services in this sample](#Services-in-this-sample)
  - [Alerting](#Alerting)
  - [Azure PostgreSQL](#Azure-PostgreSQL)
    - [Insights on metrics](#Insights-on-metrics)
    - [Alert sample](#Alert-sample)
  - [Azure Redis](#Azure-Redis)
    - [Insights on metrics](#Insights-on-metrics-1)


## Alerting

Critical Alerts will most probably wake people up and the only reason to wake people up is to get them to manually do something and monitor it. This is why critical alerts must be set only for very concrete errors that have actionables that can remedy or control the situation.

Warning Alerts can be set up most informally for informative purposes, and on top of aggregated operations on these alerts, new business rules can be used to deploy critical alerts.

- [Google's SRE book - (Chapter 5) Alerting on SLO](https://landing.google.com/sre/workbook/chapters/alerting-on-slos/)

## Azure PostgreSQL

**Interesting links:**

- [Metrics exposed by Azure Monitor (docs)](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers)
- [Monitor and Tune azure PostgreSQL](https://docs.microsoft.com/en-us/azure/postgresql/concepts-monitoring)
- [Datadog: Key metrics for PostgreSQL monitoring](https://www.datadoghq.com/blog/postgresql-monitoring/)


### Insights on metrics

These are proposed categories to give some context to these metrics:

- **CPU and Memory.**
  - CPU percent
  - Memory percent
- **Storage.** Metrics related to the underlying storage of the database. These metrics can be used to understand the growing rythm of needed storage for our DBs and could predict when disks need to be expanded or replaced.
  - IO percent.
  - Storage percent.
  - Storage used.
  - Storage limit.
- **Connectivity.** Metrics related to network connectivity and throughput. These metrics could point out configuration errors for connecting applications.
  - Active Connections.
  - Failed Connections.
  - Network In.
  - Network Out.
- **Replication Lag.** (When replication is active) Metrics that indicate lag between records stored in master node and replicas. If this lag grows too fast, could indicate significant discrepancies in consitency and could put Disaster Recovery strategies at risk
  - Replica Lag (seconds).
  - Max Lag Across Replicas (bytes).
- **Server Log storage.** Metrics that keep track the usage of disk for the Logs.
  - Server Log storage percent
  - Server Log storage used
  - Server Log storage limit

### Alert sample

These alerts in this section are helpful for our case scenario and would probably will not suit your production needs.

You can find a sample of alerts for PostgreSql here: [PostgreSql alerts](prometheus-rule-pgsql.yaml)

Note: `PrometheusRule` is a custom resource definition provided by Prometheus
Operator. You might have to change the *Metadata > Labels* section of this file
to match your own set of labels to identify Prometheus.

```bash
kubectl apply -f prometheus-rule-pgsql.yaml
```

## Azure Redis

**Interesting links:**

- [Metric definitions](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftcacheredis)
- [Azure docs: How to monitor Redis](https://docs.microsoft.com/en-us/azure/azure-cache-for-redis/cache-how-to-monitor)

### Insights on metrics

These are proposed categories to give some context to these metrics:

- **CPU and Memory.**
  - Percent Processor Time
  - Used Memory
  - Used Memory Percentage
  - Used Memory Rss
- **Operations.**
  - Total Commands Processed
  - Get Commands
  - Set Commands
  - Operations Per Second
- **Storage.**
  - Cache Hits
  - Cache Misses
  - Cache Write
  - Cache Read
  - Evicted Keys
  - Expired Keys
  - Total Keys
- **Others.**
  - Connected clients.
  - Server Load
  - Cache Latency
  - Errors

### Alert sample

These alerts in this section are helpful for our case scenario and would probably will not suit your production needs.

You can find a sample of alerts for Redis here: [Redis alerts](prometheus-rule-redis.yaml)

Note: `PrometheusRule` is a custom resource definition provided by Prometheus
Operator. You might have to change the *Metadata > Labels* section of this file
to match your own set of labels to identify Prometheus.

```bash
kubectl apply -f prometheus-rule-redis.yaml
```

