resource "azurerm_resource_group" "example" {
  name     = "databricks-rg"
  location = "Central India"
}
#workspace resource
resource "azurerm_databricks_workspace" "example" {
  name                = "databricks-test"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  sku                 = "standard"

  tags = {
    Environment = "Production"
  }
}
#cluster resource
data "databricks_node_type" "smallest" {
  depends_on = [ azurerm_databricks_workspace.example ]
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  depends_on = [ azurerm_databricks_workspace.example ]
  long_term_support = true
}
resource "databricks_instance_pool" "nodes" {
  instance_pool_name = "databricknode"
  min_idle_instances = 0
  max_capacity = 10
  node_type_id = data.databricks_node_type.smallest.id

idle_instance_autotermination_minutes = 10
}

resource "databricks_cluster" "shared_autoscaling" {
  depends_on = [ azurerm_databricks_workspace.example ]
  instance_pool_id = databricks_instance_pool.nodes.id
  cluster_name            = "Shared Autoscaling"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  autotermination_minutes = 20
  autoscale {
    min_workers = 1
    max_workers = 10
  }
  spark_conf = {
    "spark.databricks.io.cache.enabled" : true
  }
  custom_tags = {
    "created_by" = "infrateam"
  }
}