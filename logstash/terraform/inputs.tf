variable "region" {
  type = "string"
	default = "West Europe"
}

variable "resource_group" {
  type = "string"
	default = "test-logging"
}

variable "subscription_id" {
	type = "string"
}

variable "tenant_id" {
	type = "string"
}

variable "kubernetes_client_id" {
	type = "string"
}

variable "kubernetes_client_secret" {
	type = "string"
}
