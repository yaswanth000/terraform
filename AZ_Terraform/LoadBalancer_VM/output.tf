output "public_ip_address" {
  sensitive = true
  value = [azurerm_linux_virtual_machine.server1, azurerm_linux_virtual_machine.server2]
}