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

resource "random_id" "logging_kubernetes" {
  byte_length = 8
}

resource "azurerm_kubernetes_cluster" "logging_kubernetes" {
  name                = "kube-cluster-${lower(random_id.logging_kubernetes.hex)}"
  location            = "${azurerm_resource_group.scaffolded_logging_services.location}"
  resource_group_name = "${azurerm_resource_group.scaffolded_logging_services.name}"
  dns_prefix          = "kube-cluster-${lower(random_id.logging_kubernetes.hex)}"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  agent_pool_profile {
    name            = "pool2"
    count           = 1
    vm_size         = "Standard_D2_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "${var.kubernetes_client_id}"
    client_secret = "${var.kubernetes_client_secret}"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.logging_kubernetes.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.logging_kubernetes.kube_config_raw}"
}
