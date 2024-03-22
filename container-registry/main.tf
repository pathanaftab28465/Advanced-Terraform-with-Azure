provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "main" {
  name     = "${var.prefix}-taco-warehouse"
  location = var.location
}

resource "azurerm_container_registry" "main" {
  name                = "${var.prefix}tacoapp"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = "Premium"
  admin_enabled       = false

  #retention_policy {
  #  days = 14
  #  enabled = true
  #}
}


resource "azapi_update_resource" "retention_policy" {
  type        = "Microsoft.ContainerRegistry/registries@2023-01-01-preview"
  resource_id = azurerm_container_registry.main.id

  body = jsonencode({
    properties = {
      policies = {
        retentionPolicy = {
          days   = 14
          status = "enabled"
        }
      }
    }
  })
}

import {
  id = "/subscriptions/7d647b65-93d0-4240-a0be-37dcbaca013d/resourceGroups/dev-taco-warehouse/providers/Microsoft.Storage/storageAccounts/testazapistorage"
  to = azurerm_storage_account.main
}

removed {
  from = azapi_resource.storageAccount

  lifecycle {
    destroy = false
  }
}

resource "azurerm_storage_account" "main" {
  resource_group_name              = azurerm_resource_group.main.name
  location                         = azurerm_resource_group.main.location
  name                             = "testazapistorage"
  account_kind                     = "StorageV2"
  access_tier                      = "Hot"
  account_replication_type         = "LRS"
  account_tier                     = "Standard"
  cross_tenant_replication_enabled = true
  shared_access_key_enabled        = true

  queue_encryption_key_type = "Service"
  table_encryption_key_type = "Service"
  is_hns_enabled            = false
  sftp_enabled              = false
  nfsv3_enabled             = false
  min_tls_version           = "TLS1_2"
  network_rules {
    default_action = "Allow"
  }
  public_network_access_enabled   = true
  enable_https_traffic_only       = true
  default_to_oauth_authentication = false

}

/*resource "azapi_resource" "storageAccount" {
  type      = "Microsoft.Storage/storageAccounts@2021-09-01"
  parent_id = azurerm_resource_group.main.id
  name      = "testazapistorage"
  location  = var.location
  body = jsonencode({
    kind = "StorageV2"
    properties = {
      accessTier                   = "Hot"
      allowBlobPublicAccess        = true
      allowCrossTenantReplication  = true
      allowSharedKeyAccess         = true
      defaultToOAuthAuthentication = false
      encryption = {
        keySource = "Microsoft.Storage"
        services = {
          queue = {
            keyType = "Service"
          }
          table = {
            keyType = "Service"
          }
        }
      }
      isHnsEnabled      = false
      isNfsV3Enabled    = false
      isSftpEnabled     = false
      minimumTlsVersion = "TLS1_2"
      networkAcls = {
        defaultAction = "Allow"
      }
      publicNetworkAccess      = "Enabled"
      supportsHttpsTrafficOnly = true
    }
    sku = {
      name = "Standard_LRS"
    }
  })
  schema_validation_enabled = false
  response_export_values    = ["*"]
}*/