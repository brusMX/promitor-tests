# Terraform

Using terraform, you can spawn multiples services, and get the logs using an Eventhub.

That terraform set of files will spawn a Postgresql, a Redis and a Kubernetes cluster. Then the logs will be collected by 3 differents Eventhub, then logstash can scrap the eventhubs and send the logs to elasticsearch.

## Organization

  inputs.tf       -> mandatory and facultatives variables
  providers.tf    -> azure provider configuration
  scaffolding.tf  -> deployment of services for testing (postgres, redis, k8s)
  topology.tf     -> eventhub


## Deploying

Azure CLI must be installed, and you must be logged.

  az login --service-principal --username user --password f0980a23-c33d-433b-82c1-7322c303de39 --subscription d5baefd9-fe3c-41ae-b62c-97113616be3a --tenant 74796a79-4f90-47d1-859d-7397ad225231

You must have a client_id and a client_secret for the deployment of kubernetes, or create one with

  az ad sp create-for-rbac --skip-assignment

Then plan and/or apply the configuration

  terraform apply -var='subscription_id=7451b8a1-28a8-48c1-9f52-fcbbb137a11d' -var='tenant_id=0333ca35-3f21-4f69-abef-c46d541d019d' -var='kubernetes_client_id=' -var='kubernetes_client_secret='

Mandatory variables:
 - subscription_id
 - tenant_id
 - kubernetes_client_id
 - kubernetes_client_secret

Optional variables:
 - region
 - resource_group


### 
