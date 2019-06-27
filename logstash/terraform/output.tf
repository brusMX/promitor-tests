output "storage_connection_string" {
    value = "${azurerm_storage_account.logging.primary_connection_string}"
}

output "postgresql_eventhub_connection_string" {
    value = "${azurerm_eventhub_namespace_authorization_rule.logging.primary_connection_string};EntityPath=${azurerm_eventhub.logging_postgresql.name}"
}
