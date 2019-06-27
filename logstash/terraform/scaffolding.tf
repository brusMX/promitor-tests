resource "azurerm_resource_group" "scaffolded_logging_services" {
  name     = "${var.resource_group}_services"
  location = "${var.region}"
}

resource "random_id" "logging_postgresql" {
  byte_length = 8
}

resource "azurerm_postgresql_server" "logging_postgresql" {
  name                = "postgresql-server-${lower(random_id.logging_postgresql.hex)}"
  location            = "${azurerm_resource_group.scaffolded_logging_services.location}"
  resource_group_name = "${azurerm_resource_group.scaffolded_logging_services.name}"

  sku {
    name     = "B_Gen5_2"
    capacity = 2
    tier     = "Basic"
    family   = "Gen5"
  }

  storage_profile {
    storage_mb            = 5120
    backup_retention_days = 7
    geo_redundant_backup  = "Disabled"
  }

  administrator_login          = "psqladmin"
  administrator_login_password = "H@Sh1CoR3!"
  version                      = "9.5"
  ssl_enforcement              = "Disabled"
}

data "azurerm_monitor_diagnostic_categories" "postgres_logs" {
  resource_id = "${azurerm_postgresql_server.logging_postgresql.id}"
}

resource "random_id" "logging_redis" {
  byte_length = 8
}

resource "azurerm_redis_cache" "logging_redis" {
  name                = "redis-cache-${lower(random_id.logging_redis.hex)}"
  location            = "${azurerm_resource_group.scaffolded_logging_services.location}"
  resource_group_name = "${azurerm_resource_group.scaffolded_logging_services.name}"
  capacity            = 2
  family              = "C"
  sku_name            = "Standard"
  enable_non_ssl_port = true
  minimum_tls_version = "1.2"

  redis_configuration {}
}

data "azurerm_monitor_diagnostic_categories" "redis_logs" {
  resource_id = "${azurerm_redis_cache.logging_redis.id}"
}

resource "random_id" "logging_kubernetes" {
  byte_length = 8
}

resource "azurerm_kubernetes_cluster" "logging_kubernetes" {
  name                = "kube-cluster-${lower(random_id.logging_kubernetes.hex)}"
  location            = "${azurerm_resource_group.scaffolded_logging_services.location}"
  resource_group_name = "${azurerm_resource_group.scaffolded_logging_services.name}"
  dns_prefix          = "kube-cluster-${lower(random_id.logging_kubernetes.hex)}"

  agent_pool_profile {
    name            = "pool1"
    count           = 2
    vm_size         = "Standard_D2_v3"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.kubernetes_client_id}"
    client_secret = "${var.kubernetes_client_secret}"
  }
}

resource "local_file" "kube_config" {
  content  = "${azurerm_kubernetes_cluster.logging_kubernetes.kube_config_raw}"
  filename = "kube-cluster-${lower(random_id.logging_kubernetes.hex)}"
}

data "azurerm_monitor_diagnostic_categories" "aks_logs" {
  resource_id = "${azurerm_kubernetes_cluster.logging_kubernetes.id}"
}

resource "random_id" "function_storage_name" {
  byte_length = 8
}

resource "azurerm_storage_account" "function_storage" {
  name                     = "functionsapp2019"
  resource_group_name      = "${azurerm_resource_group.scaffolded_logging_services.name}"
  location                 = "${azurerm_resource_group.scaffolded_logging_services.location}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_app_service_plan" "functionplan" {
  name                = "azure-functions-service-plan"
  resource_group_name = "${azurerm_resource_group.scaffolded_logging_services.name}"
  location            = "${azurerm_resource_group.scaffolded_logging_services.location}"
  kind                = "FunctionApp"
  reserved            = true

  sku {
    tier = "Dynamic"
    size = "Y1"
  }
}

resource "random_id" "functionapp" {
  byte_length = 8
}

resource "azurerm_function_app" "functionapp" {
  name                      = "azure-functions-${lower(random_id.functionapp.hex)}"
  resource_group_name       = "${azurerm_resource_group.scaffolded_logging_services.name}"
  location                  = "${azurerm_resource_group.scaffolded_logging_services.location}"
  app_service_plan_id       = "${azurerm_app_service_plan.functionplan.id}"
  storage_connection_string = "${azurerm_storage_account.function_storage.primary_connection_string}"
  enable_builtin_logging    = true
  enabled                   = true
  https_only                = true
  version                   = "~2"

  site_config {
    use_32_bit_worker_process = false
  }

  app_settings = {
    "APPINSIGHTS_INSTRUMENTATIONKEY" = "${azurerm_application_insights.appinsights.instrumentation_key}"
  }
}
