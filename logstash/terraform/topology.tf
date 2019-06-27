resource "azurerm_resource_group" "logging" {
  name     = "${var.resource_group}"
  location = "${var.region}"
}

resource "random_id" "storage_account" {
  byte_length = 8
}

resource "azurerm_storage_account" "logging" {
  name                     = "tfsta${lower(random_id.storage_account.hex)}"
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

resource "random_id" "eventhub" {
  byte_length = 8
}

resource "azurerm_eventhub_namespace" "logging" {
  name                = "logging-eventhub-namespace-${lower(random_id.eventhub.hex)}"
  location            = "${azurerm_resource_group.logging.location}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  sku                 = "Standard"
  capacity            = 1
  kafka_enabled       = false
}

resource "azurerm_eventhub" "logging_postgresql" {
  name                = "logging-postgresql-eventhub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_redis" {
  name                = "logging-redis-eventhub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_aks" {
  name                = "logging-aks-eventhub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub" "logging_az_functions" {
  name                = "logging-az-functions-eventhub"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"
  partition_count     = 2
  message_retention   = 1
}

resource "azurerm_eventhub_namespace_authorization_rule" "logging" {
  name                = "authorization_rule"
  namespace_name      = "${azurerm_eventhub_namespace.logging.name}"
  resource_group_name = "${azurerm_resource_group.logging.name}"

  listen = true
  send   = true
  manage = true
}

resource "azurerm_monitor_diagnostic_setting" "postgre-logging" {
  name                           = "diagnostic_postgresql"
  target_resource_id             = "${azurerm_postgresql_server.logging_postgresql.id}"
  eventhub_name                  = "${azurerm_eventhub.logging_postgresql.name}"
  eventhub_authorization_rule_id = "${azurerm_eventhub_namespace_authorization_rule.logging.id}"

  log {
    category = "PostgreSQLLogs"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "QueryStoreRuntimeStatistics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "QueryStoreWaitStatistics"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}

resource "azurerm_monitor_diagnostic_setting" "aks-logging" {
  name                           = "diagnostic_aksl"
  target_resource_id             = "${azurerm_kubernetes_cluster.logging_kubernetes.id}"
  eventhub_name                  = "${azurerm_eventhub.logging_aks.name}"
  eventhub_authorization_rule_id = "${azurerm_eventhub_namespace_authorization_rule.logging.id}"

  log {
    category = "kube-scheduler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-controller-manager"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "cluster-autoscaler"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-audit"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }

  log {
    category = "kube-apiserver"
    enabled  = true

    retention_policy {
      enabled = false
    }
  }
}
