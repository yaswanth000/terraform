resource "azurerm_resource_group" "example" {
  name     = "function-rg"
  location = "East Asia"
}

resource "azurerm_storage_account" "examplefunctionstorage" {
  name                     = "examplepythonfuction"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

resource "azurerm_service_plan" "example" {
  name                = "example-service-plan"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  os_type             = "Linux"
  sku_name            = "S1"
}
# App Service Plan for Function App
# resource "azurerm_app_service_plan" "example" {
#   name                = "azure-functions-example-sp"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   kind                = "Linux"
#   reserved            = true
#   sku {
#     tier = "Static"
#     size = "S1"
#   }
# }

# resource "azurerm_function_app" "example" {
#   name                       = "example-azure-function"
#   location                   = azurerm_resource_group.example.location
#   resource_group_name        = azurerm_resource_group.example.name
#   app_service_plan_id        = azurerm_service_plan.example.id
#   storage_account_name       = azurerm_storage_account.examplefunctionstorage.name
#   storage_account_access_key = azurerm_storage_account.examplefunctionstorage.primary_access_key
#   os_type                    = "linux"
#   version                    = "~4"

#   app_settings = {
#     FUNCTIONS_WORKER_RUNTIME = "python"
#   }

#   site_config {
#     linux_fx_version = "python|3.9"
#     always_on        = true
#   }
# }

##########################
resource "azurerm_linux_function_app" "example" {
  name                = "function-app-testpythonsample"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  service_plan_id     = azurerm_service_plan.example.id

  storage_account_name       = azurerm_storage_account.examplefunctionstorage.name
  storage_account_access_key = azurerm_storage_account.examplefunctionstorage.primary_access_key

  site_config {
    application_stack {
      python_version = "3.9"
    }
  }
}

resource "azurerm_function_app_function" "example" {
  name            = "example-function-app-function"
  function_app_id = azurerm_linux_function_app.example.id
  language        = "Python"

  file {
    name    = "function_app.py"
    content = file("function_app.py")
  }

  test_data = jsonencode({
    "name" = "Azure"
  })
  config_json = jsonencode({
    "bindings" = [
      {
        "authLevel" = "function"
        "direction" = "in"
        "methods" = [
          "get",
          "post",
        ]
        "name" = "req"
        "type" = "httpTrigger"
      },
      {
        "direction" = "out"
        "name"      = "$return"
        "type"      = "http"
      },
    ]
  })
}

#######################