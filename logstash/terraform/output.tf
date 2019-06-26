output "Storage Connection String" {
    value = "${azurerm_storage_account.logging.primary_connection_string}"
}

output "PostgreSQL EventHub Connection String" {
    value = "${azurerm_eventhub_namespace_authorization_rule.logging.primary_connection_string};${azurerm_eventhub.logging_postgresql.name}"
}

