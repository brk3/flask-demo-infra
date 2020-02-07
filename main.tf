# NOTE(pbourke): Use the following commands to register the correct resource providers
# TODO(pbourke): Find out why this is
# > Connect-AzAccount
# > Register-AzResourceProvider -ProviderNamespace 'Microsoft.ContainerRegistry'

#terraform {
  #backend "azurerm" {
    #resource_group_name  = "tstate"
    #storage_account_name = "tstateXXX"
    #container_name       = "tstate"
    #key                  = "terraform.tfstate"
  #}
#}

provider "azurerm" {
  # https://registry.terraform.io/providers/hashicorp/azurerm
  version = "=1.41.0"
}

resource "azurerm_resource_group" "rg" {
  name     = "${var.prefix}resourcegroup"
  location = var.location
}

resource "azurerm_storage_account" "sa" {
  name                     = "${var.prefix}storageaccount"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "sc" {
  name                  = "${var.prefix}storagecontainer"
  storage_account_name  = azurerm_storage_account.sa.name
  container_access_type = "private"
}

data "azurerm_storage_account_sas" "sas" {
  connection_string = "${azurerm_storage_account.sa.primary_connection_string}"

  resource_types {
    service   = false
    container = false
    object    = true
  }

  services {
    blob  = true
    queue = false
    table = false
    file  = false
  }

  start  = "2020-01-01"
  expiry = "2021-01-01"

  permissions {
    read    = false
    write   = true
    delete  = false
    list    = false
    add     = false
    create  = false
    update  = false
    process = false
  }
}

resource "azurerm_container_registry" "cr" {
  name                = "${var.prefix}containerregistry"
  sku                 = var.container_registry_sku
  admin_enabled       = true
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
}

resource "azurerm_app_service_plan" "aps" {
  name                = "${var.prefix}appserviceplan"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  kind                = "Linux"
  reserved            = true

  sku {
    tier = "Standard"
    size = "S1"
  }
}

resource "azurerm_app_service" "as" {
  name                = "${var.prefix}appservice"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  app_service_plan_id = azurerm_app_service_plan.aps.id

  site_config {
    linux_fx_version = "DOCKER|${azurerm_container_registry.cr.login_server}/${var.app_service_image}"
  }

  app_settings = {
    "WEBSITES_PORT"                   = "5000"
    "DOCKER_REGISTRY_SERVER_URL"      = "https://${azurerm_container_registry.cr.login_server}"
    "DOCKER_REGISTRY_SERVER_USERNAME" = azurerm_container_registry.cr.admin_username
    "DOCKER_REGISTRY_SERVER_PASSWORD" = azurerm_container_registry.cr.admin_password
  }


  backup {
    name                = "Backup"
    storage_account_url = "https://${azurerm_storage_account.sa.name}.blob.core.windows.net/${azurerm_storage_container.sc.name}${data.azurerm_storage_account_sas.sas.sas}&sr=b"

    schedule {
      frequency_interval = "30"
      frequency_unit     = "Day"
    }
  }
}

resource "azurerm_application_insights" "ai" {
  name                = "${var.prefix}appinsights"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  application_type    = "other"
}

module "sqldatabase" {
  source = "./sqldatabase"

  prefix                = var.prefix
  resource_group_name   = azurerm_resource_group.rg.name
  location              = azurerm_resource_group.rg.location
  sql_firewall_ip_start = var.sql_firewall_ip_start
  sql_firewall_ip_end   = var.sql_firewall_ip_end
}
