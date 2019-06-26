resource "azurerm_resource_group" "scaffolded_logging_services" {
  name     = "${var.resource_group}_services"
  location = "${var.region}"
}

resource "random_string" "logging_postgresql" {
  length  = 10
  special = false
}

resource "azurerm_postgresql_server" "logging_postgresql" {
  name                = "postgresql-server-${random_string.logging_postgresql.result}"
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

