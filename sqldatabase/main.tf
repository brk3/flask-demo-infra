provider "random" {
  version = "=2.2"
}

resource "random_password" "pw" {
  length  = 16
  special = true
}

resource "azurerm_sql_server" "ss" {
  name                = "${var.prefix}sqlserver"
  resource_group_name = var.resource_group_name
  location            = var.location
  version             = "12.0"
  # TODO(pbourke): how to secure these?
  administrator_login          = "asystec"
  administrator_login_password = random_password.pw.result
}

resource "azurerm_sql_database" "db" {
  name                = "${var.prefix}sqldatabase"
  resource_group_name = var.resource_group_name
  location            = var.location
  server_name         = azurerm_sql_server.ss.name
}

resource "azurerm_sql_firewall_rule" "fw" {
  # TODO(pbourke): add prefix
  name                = "firewallrule1"
  resource_group_name = var.resource_group_name
  server_name         = azurerm_sql_server.ss.name
  start_ip_address    = var.sql_firewall_ip_start
  end_ip_address      = var.sql_firewall_ip_end
}
