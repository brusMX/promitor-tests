# A word about interesting metrics

## Alerting

Critical Alerts will most probably wake people up and the only reason to wake people up is to get them to manually do something and monitor it. This is why critical alerts must be set only for very concrete errors that have actionables that can remedy or control the situation.

Warning Alerts can be set up most informally for informative purposes, and on top of aggregated operations on these alerts, new business rules can be used to deploy critical alerts

## Services in this sample

For this repository we will focus on 3 popular services:

- Azure PostgreSQL
- Azure Redis
- Azure Kubernetes Services

This document intends to do a brief analysis and give an opinion on how these metrics can be used for SRE teams.

## Azure PostgreSQL

- [Metrics exposed by Azure Monitor (docs)](https://docs.microsoft.com/en-us/azure/azure-monitor/platform/metrics-supported#microsoftdbforpostgresqlservers)

These are proposed categories to give some context to these metrics:

- **CPU and Memory.**
  - CPU percent
  - Memory percent
- **Storage.** Metrics related to the underlying storage of the database. These metrics can be used to understand the growing rythm of needed storage for our DBs and could predict when disks need to be expanded.
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

### Insights

Storage