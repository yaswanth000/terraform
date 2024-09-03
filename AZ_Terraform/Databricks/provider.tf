terraform {
    required_providers {
      databricks = {
      source = "databricks/databricks"
      version = "0.3.1"
      }
    }
}
provider "databricks" {
  azure_workspace_resource_id = azurerm_databricks_workspace.example.id
  azure_client_id="ad430cc5-7af2-4ecc-9416-5ff92577028b"
  azure_client_secret="ssd8Q~c7wy2pVEingbgPePEWbr6Z~Bm5H_6A3cJO"
  azure_tenant_id="f37a82eb-7cbc-45be-9d2e-da109f6380ca"
}
provider "azurerm" {
  features {}
  client_id="ad430cc5-7af2-4ecc-9416-5ff92577028b"
  client_secret="ssd8Q~c7wy2pVEingbgPePEWbr6Z~Bm5H_6A3cJO"
  tenant_id="f37a82eb-7cbc-45be-9d2e-da109f6380ca"
  subscription_id="dd872814-1a50-4e92-98d4-d7357d4bf74a"
}