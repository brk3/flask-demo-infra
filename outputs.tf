output "container_registry" {
  value = azurerm_container_registry.cr.name
}

output "database_password" {
  value = module.sqldatabase.DatabasePassword
}

output "instrumentation_key" {
  value = azurerm_application_insights.ai.instrumentation_key
}
