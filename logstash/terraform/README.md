# Terraform

Using terraform, you can spawn multiples services, and get the logs using an Eventhub.

That terraform set of files will spawn a Postgresql, a Redis and a Kubernetes cluster. Then the logs will be collected by 3 differents Eventhub, logstash can scrap the eventhubs and send the logs to elasticsearch.


## Prerequistes

You need to have **Terraform** and **Helm** executables in one of the PATH directory (/bin, /usr/local/bin, ...).

Azure CLI must be installed.


## Organization

```
  inputs.tf       -> mandatory and facultatives variables
  output.tf       -> outputs from terraform
  providers.tf    -> azure provider configuration
  scaffolding.tf  -> deployment of services for testing (postgres, redis, k8s)
  topology.tf     -> eventhub
```


## Deploying

Azure CLI must be installed, and you must be logged.

```
az login --service-principal --username user --password f0980a23-c33d-433b-82c1-7322c303de39 --subscription d5baefd9-fe3c-41ae-b62c-97113616be3a --tenant 74796a79-4f90-47d1-859d-7397ad225231
```

You must have a client_id and a client_secret for the deployment of kubernetes, or create one with

```
az ad sp create-for-rbac --skip-assignment
```

Then plan and/or apply the configuration

```
terraform init

terraform apply -var='subscription_id=7451b8a1-28a8-48c1-9f52-fcbbb137a11d' -var='tenant_id=0333ca35-3f21-4f69-abef-c46d541d019d' -var='kubernetes_client_id=7bd471ef-0774-419b-9b65-5dda1055d4c3' -var='kubernetes_client_secret=e381419b-c1e6-43ee-9338-9f466dd8cfdb'
```

Mandatory variables:
 - subscription_id
 - tenant_id
 - kubernetes_client_id
 - kubernetes_client_secret

Optional variables:
 - region
 - resource_group

Terraform will generate a kubeconfig file to provide credentials to connect to kubernetes, the file is located in the current working directory and is named after the kubernetes cluster name.

you can test the kubernetes cluster connectivity with this following command

```
kubectl --kubeconfig=kube-cluster-af9c506364e4fd3d get cs
```
