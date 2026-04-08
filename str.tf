resource "azurerm_storage_account" "portfolio_sa" {
  name                     = "sushmiportfoliosa88"
  resource_group_name      = azurerm_resource_group.rg.name
  location                 = azurerm_resource_group.rg.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_storage_container" "images" {
  name                  = "images"
  storage_account_name  = azurerm_storage_account.portfolio_sa.name  
  container_access_type = "blob"
}

resource "azurerm_storage_blob" "profile_photo" {
  name                   = "sushmi.jpg"
  storage_account_name   = azurerm_storage_account.portfolio_sa.name
  storage_container_name = azurerm_storage_container.images.name
  type                   = "Block"
  source                 = "C:/Users/susmi/OneDrive/Desktop/sushmithaa.jpeg"
}
