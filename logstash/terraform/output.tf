output "storage_connection_string" {
  value = "${azurerm_storage_account.logging.primary_connection_string}"
}

output "function_storage_connection_string" {
  value = "${azurerm_storage_account.function_storage.primary_connection_string}"
}

output "postgresql_eventhub_connection_string" {
  value = "${azurerm_eventhub_namespace_authorization_rule.logging.primary_connection_string};EntityPath=${azurerm_eventhub.logging_postgresql.name}"
}

output "postgres_logs" {
  value = "${data.azurerm_monitor_diagnostic_categories.postgres_logs.logs}"
}

output "postgres_metrics" {
  value = "${data.azurerm_monitor_diagnostic_categories.postgres_logs.metrics}"
}

output "redis_logs" {
  value = "${data.azurerm_monitor_diagnostic_categories.redis_logs.logs}"
}

output "redis_metrics" {
  value = "${data.azurerm_monitor_diagnostic_categories.redis_logs.metrics}"
}

output "aks_logs" {
  value = "${data.azurerm_monitor_diagnostic_categories.aks_logs.logs}"
}

output "aks_metrics" {
  value = "${data.azurerm_monitor_diagnostic_categories.aks_logs.metrics}"
}
