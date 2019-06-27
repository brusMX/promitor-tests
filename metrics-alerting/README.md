# A word about interesting metrics

This document intends to do a brief analysis and give an opinion on how these metrics can be used for SRE teams to have insights on their monitored systems.


## Services in this sample

For this repository we will focus on 3 popular services:

- [A word about interesting metrics](#A-word-about-interesting-metrics)
  - [Services in this sample](#Services-in-this-sample)
  - [Alerting](#Alerting)
    - [About severities](#About-severities)
  - [Azure PostgreSQL](#Azure-PostgreSQL)
    - [Insights on metrics](#Insights-on-metrics)
    - [Alert sample](#Alert-sample)
      - [High CPU usage](#High-CPU-usage)
      - [Number of failed connection grows significantly](#Number-of-failed-connection-grows-significantly)
      - [Storage will be full in roughly 4 hours](#Storage-will-be-full-in-roughly-4-hours)
  - [Azure Redis](#Azure-Redis)
    - [Insights on metrics](#Insights-on-metrics-1)
    - [Alert sample](#Alert-sample-1)
      - [High CPU usage](#High-CPU-usage-1)
      - [High server load](#High-server-load)
      - [Errors detected](#Errors-detected)


## Alerting

Critical Alerts will most probably wake people up and the only reason to wake people up is to get them to manually do something and monitor it. This is why critical alerts must be set only for very concrete errors that have actionables that can remedy or control the situation.

Warning Alerts can be set up most informally for informative purposes, and on top of aggregated operations on these alerts, new business rules can be used to deploy critical alerts.

- [Google's SRE book - (Chapter 5) Alerting on SLO](https://landing.google.com/sre/workbook/chapters/alerting-on-slos/)

### About severities

**Warning**

Alerts set with label "warning" are handled as IM messages only: they don't
go to our paging management tool of choice.
So they are mostly informational.

Also we can display those in Grafana dashboards since they are available in the
`ALERTS` metric and they can also be part of a kind of "status aggregation"
alert: you can consider your service in "yellow" status if there is at least one
warning alert.

We strongly recommend to have a runbook URL set for such alerts to tell about
how you can investigate & resolve the issue but we don't enforce it on warning
alerts.

**Critical**

Alerts set with label "critical" are handled as IM messages but they are also
sent to our paging management tool: those will definitiely ask for an operator
to take a look and fix the issue.

We can use those alerts as part of the "status aggregation" alert: your service
is in red status if here is at least one critical alert.

For those we enforce the presence if a runbook URL: an operator must hae a
documentation on how to investigate & resolve the issue described by the alert.

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

These alerts in this section are helpful for our case scenario and would probably
will not suit your production needs.

In order to deploy those alerts we are using a Kubernetes Custom Resource Definition
called `PrometheusRule`. This CRD is provided by the Prometheus Operator.

Note: You might have to change the *Metadata > Labels* section of those file
to match your own set of labels. This section is about telling the Prometheus Operator
controller about which Prometheus must handle the alerts described in the
`PrometheusRule` object.

You can find a sample of alerts for PostgreSql here: [PostgreSql alerts](prometheus-rule-pgsql.yaml)

To deploy those alerts in your Prometheus:

```bash
kubectl apply -f prometheus-rule-pgsql.yaml
```

#### High CPU usage

This alert is meant to warn us when our database server is burning all its CPU
for an unusual period of time.

Expression:

```yaml
expr: |-
  azmon_pgsql_cpu_percent > 90
for: 5m
labels:
  severity: warning
```

This PromQL query is straightforward since the base metrics is expressed as a
percentage:
* We use a simple threshold of 90%
* The alert must stay for 5 minutes until it is confirmed by Prometheus &
  processed by Alertmanager.
* The query does not use any filtering: this alert will be raised for any
  PostgreSql server whatsoever.

This alert is set as a *warning* since there is no operation that has been
identiied to solve this issue. This is only informational so people can see it on
Slack or dashboards.

#### Number of failed connection grows significantly

This alert is meant to tell us if our applications are failing to connect
properly to the database server.

Expression:

```yaml
expr: |-
  deriv(
    azmon_pgsql_connections_failed_total[5m]
  ) > 0.1
for: 5m
labels:
  severity: warning
```

For this alert we choosed to use the `deriv()` operator in order to alert on
the growth of number of failed connection. The metric itself can be tricky
to alert on since it is an absolute value and you have no total to compare it to
: so you can't do a ratio.

Though alerting on the acceleration of the number of failed connection makes it
a bit easier: if your number of failed connection is increasing you have something
wrong happenning.

The threshold have been tailored to our own observation of this graph: you will
probably have to adjust it for your own use case.

Since there are no operation identified to solve this issue: the alert is kept
in warning severity.

#### Storage will be full in roughly 4 hours

This alert is meant to warn us if the storage is expecting to be full in the
near future.

Expression:

```yaml
expr: |-
  predict_linear(
    azmon_pgsql_storage_percent[30m],
    4 * 3600
  ) >= 95
for: 5m
labels:
  severity: warning
```

To achieve such a prediction we use PromQL's `predict_linear` operator which
is telling you what would be the value of your metric in some time **if** the
evolution of your metric follows the same rate as of now.

We choosed to use a 30 minutes time range for the linear prediction: so the 
evolution of the metric is calculated on the last 30 minutes.

The metric is expressed in percent so we can compare it to a simple 95% threshold.

As of now we keep this alert as a warning until we have devised a proper procedure
for such issue: either have a cleanup job or the capacity to increase database
storage on the fly through infrastructure code.

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

#### High CPU usage

This alert is meant to warn us if our Redis clusters are burning all their CPU
for an unusual period of time.

Expression:

```yaml
expr: |
  azure_redis_cache_percent_processor_time > 80
for: 5m
labels:
  severity: warning
```

As for the CPU alert for PostgreSql this one is pretty straightforward.
Ans as usual we keep it as a warning since there is no operation defined to
solce this issue.

#### High server load

This alert is meant to warn us if our Redis clusters are under heavy load.

Expression:

```yaml
expr: |
  azure_redis_cache_server_load > 80
for: 5m
labels:
  severity: warning
```

This alert is based on a metric given by Redis itself and is close to be
expressed in a percent: if your server reach 100 then it cannot process new
requests anymore.

#### Errors detected

This alert is meant to warn us if some errors have been detected by Azure on our
Redis clusters.

Expression:

```yaml
expr: |-
  azure_redis_cache_errors > 0
for: 1m
labels:
  severity: warning
```

This alert relies also on Redis output processed by Azure Monitor so lots of 
different errors are collected & aggregated in this metric.

As a first sample we want to get informed if there is any error detected but this
threshold will definitiely be adapted in the future.

Also as soon as we can refine the metric and pick only some of the dimensions
available in this metric we will focus on specific error types instead of
aggregating all of them.
