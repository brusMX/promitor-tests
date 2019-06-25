resource "azurerm_resource_group" "logging" {
  name     = "${var.resource_group}"
  location = "${var.region}"
}

resource "azurerm_storage_account" "logging" {
  name                     = "acctestaccs"
  resource_group_name      = "${azurerm_resource_group.logging.name}"
  location                 = "${var.region}"
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "logging" {
  name                  = "vhds"
  resource_group_name   = "${azurerm_resource_group.logging.name}"
  storage_account_name  = "${azurerm_storage_account.logging.name}"
  container_access_type = "private"
}

resource "azurerm_storage_blob" "logging" {
  name = "eventhub_storage.vhd"

  resource_group_name    = "${azurerm_resource_group.logging.name}"
  storage_account_name   = "${azurerm_storage_account.logging.name}"
  storage_container_name = "${azurerm_storage_container.logging.name}"

  type = "block"
}

resource "azurerm_eventhub_namespace" "logging" {
  name                = "LoggingEventHubNamespace"
  location            = "${azurerm_resource_group.logging.location}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  sku                 = "Standard"
  capacity            = 1
  kafka_enabled       = false
}

resource "azurerm_eventhub" "logging_postgresql" {
  name                = "LoggingPostgresqlEventHub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_redis" {
  name                = "LoggingRedisEventHub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_aks" {
  name                = "LoggingAksEventHub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_az_functions" {
  name                = "LoggingAzFunctionsEventHub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}
