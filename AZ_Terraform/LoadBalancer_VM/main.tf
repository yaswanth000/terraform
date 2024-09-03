resource "azurerm_resource_group" "example" {
  name     = "LoadBalancerRG"
  location = "Central India"
}
# Create virtual network
resource "azurerm_virtual_network" "example" {
  name                = "example-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
}

resource "azurerm_subnet" "example" {
  name                 = "mysubnet"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.2.0/24"]
}
# Create Network Security Group and rules
resource "azurerm_network_security_group" "example" {
  name                = "lb-sg-SecurityGroup1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
 
  security_rule {
    name                       = "Allowanyhttp"
    priority                   = 210
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  # security_rule {
  #   name                       = "lb-sg"
  #   priority                   = 1001
  #   direction                  = "Inbound"
  #   access                     = "Allow"
  #   protocol                   = "tcp"
  #   source_port_range          = "*"
  #   destination_port_range     = "80"
  #   source_address_prefix      = "*"
  #   destination_address_prefix = "*"
  # }
  security_rule {
    name                       = "allow-ssh"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}


resource "azurerm_network_interface" "nic1" {
  name                = "example-nic1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                                    = "internal"
    subnet_id                               = azurerm_subnet.example.id
    private_ip_address_allocation           = "Dynamic"
#    public_ip_address_id = azurerm_public_ip.example.id

  }
}
# Create network interface
resource "azurerm_network_interface" "nic2" {
  name                = "example-nic2"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                                    = "internal"
    subnet_id                               = azurerm_subnet.example.id
    private_ip_address_allocation           = "Dynamic"
#    public_ip_address_id = azurerm_public_ip.example.id
  }
}
# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "az_nsg_security1" {
  network_interface_id = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.example.id
}
resource "azurerm_network_interface_security_group_association" "az_nsg_security2" {
  network_interface_id = azurerm_network_interface.nic2.id
  network_security_group_id = azurerm_network_security_group.example.id
}
# Create public IPs
resource "azurerm_public_ip" "example" {
  name                = "Public-IP"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku                 = "Standard"
}
#creating loadbalancer
resource "azurerm_lb" "example" {
  name                = "virtualLoadBalancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku                 = "standard"
  sku_tier            = "Regional"

  frontend_ip_configuration {
    name                 = "PublicIPAddress"
    public_ip_address_id = azurerm_public_ip.example.id
  }
}

resource "azurerm_lb_backend_address_pool" "example" {
  loadbalancer_id = azurerm_lb.example.id
  name            = "BackEndAddressPool"
}
resource "azurerm_network_interface_backend_address_pool_association" "az_pool_association_nic1" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  network_interface_id    = azurerm_network_interface.nic1.id
  ip_configuration_name   = "internal"
}

resource "azurerm_network_interface_backend_address_pool_association" "az_pool_association_nic2" {
  backend_address_pool_id = azurerm_lb_backend_address_pool.example.id
  network_interface_id    = azurerm_network_interface.nic2.id
  ip_configuration_name   = "internal"
}

resource "azurerm_lb_probe" "example" {
  resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.example.id
  name                = "http-running-probe"
  protocol            = "http"
  port                = 80
  request_path        = "/"
  interval_in_seconds = 15
  number_of_probes    = 2
}

resource "azurerm_lb_rule" "example" {
  resource_group_name            = azurerm_resource_group.example.name
  name                           = "example-lb-rule"
  loadbalancer_id                = azurerm_lb.example.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = azurerm_lb.example.frontend_ip_configuration[0].name
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.example.id]
  probe_id                       = azurerm_lb_probe.example.id
}

# resource "azurerm_network_interface" "linux_nic" {
#   name                = "example-linux-nic"
#   location            = azurerm_resource_group.example.location
#   resource_group_name = azurerm_resource_group.example.name
#   # subnet_id           = azurerm_subnet.example.id
#   # network_security_group_id = azurerm_network_security_group.example.id

#   ip_configuration {
#     name                          = "example-ip-config"
#     subnet_id                     = azurerm_subnet.example.id
#     private_ip_address_allocation = "Dynamic"
#     # load_balancer_backend_address_pool_ids = [
#     #   azurerm_lb_backend_address_pool.example.id,
#     # ]
#   }
# }


resource "tls_private_key" "secureadmin_ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "azurerm_linux_virtual_machine" "server1" {
  name                  = "vm-machine1"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic1.id]


  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  custom_data = filebase64("userdata.sh") # Base64 encoded user data

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

resource "azurerm_linux_virtual_machine" "server2" {
  name                  = "vm-machine2"
  resource_group_name   = azurerm_resource_group.example.name
  location              = azurerm_resource_group.example.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.nic2.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = tls_private_key.secureadmin_ssh.public_key_openssh
  }

  custom_data = filebase64("userdata2.sh") # Base64 encoded user data

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}



#https://github.com/Texiio-organization/Terraform-vm-lb/blob/main/main.tf