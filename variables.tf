variable "prefix" {}

variable "location" {}

variable "container_registry_sku" {
  type    = string
  default = "Basic"
}

variable "app_service_image" {
  type    = string
  default = "flask-demo:latest"
}

variable "sql_firewall_ip_start" {
  type    = string
  default = "0.0.0.0"
}

variable "sql_firewall_ip_end" {
  type    = string
  default = "0.0.0.0"
}
