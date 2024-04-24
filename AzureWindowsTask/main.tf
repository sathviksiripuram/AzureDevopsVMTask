terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "3.98.0"
    }
  }
}

provider "azurerm" {
  subscription_id = "Enter your subscription_id"
  client_id = "Enter your  client_id"
  client_secret = "Enter your client_secret"
  tenant_id = "Enetr your tenant_id"
  features {
    
  }
  
}
resource "azurerm_resource_group" "example" {
  name = "Task"
  location = "Central India"
}
locals {
  resource_group="Task1"
  location="Central India"  
}

resource "azurerm_virtual_network" "example" {
  name                = "vnet"
  location            = local.location
  resource_group_name = azurerm_resource_group.example.name
  address_space       = ["10.0.0.0/16"]
  

  
  depends_on = [ azurerm_resource_group.example ]
 
}

resource "azurerm_subnet" "SubnetA" {
  name                 = "SubnetA"
  resource_group_name  = azurerm_resource_group.example.name
  virtual_network_name = azurerm_virtual_network.example.name
  address_prefixes     = ["10.0.0.0/16"]
  depends_on = [
    azurerm_virtual_network.example
  ]
}
resource "azurerm_public_ip" "example" {
  name                = "ip-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

  
  }
resource "azurerm_network_interface" "main" {
  name                = "interface"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example.id
  }
  depends_on = [ azurerm_virtual_network.example,
  azurerm_public_ip.example]
}

resource "azurerm_windows_virtual_machine" "example" {
  name                = "vm-1"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"
  admin_username      = "AzureTask"
  admin_password      = "Azure@Adtech"
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.main.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.main,
    azurerm_availability_set.app_set
  ]
}
resource "azurerm_public_ip" "example1" {
  name                = "ip-2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  allocation_method   = "Static"

  
  }
resource "azurerm_network_interface" "main1" {
  name                = "interface1"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  ip_configuration {
    name                          = "internal1"
    subnet_id                     = azurerm_subnet.SubnetA.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.example1.id
    
  }
  depends_on = [ azurerm_virtual_network.example,
  azurerm_subnet.SubnetA,
  azurerm_public_ip.example
  
  ]
}

resource "azurerm_windows_virtual_machine" "example1" {
  name                = "vm-2"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  size                = "Standard_D2s_v3"
  admin_username      = "AzureTask"
  admin_password      = "Azure@Adtech"
  availability_set_id = azurerm_availability_set.app_set.id
  network_interface_ids = [
    azurerm_network_interface.main1.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  depends_on = [
    azurerm_network_interface.main1,
    azurerm_availability_set.app_set
  ]
}
resource "azurerm_availability_set" "app_set" {
  name                = "availability_set"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  platform_fault_domain_count = 3
  platform_update_domain_count = 3  
  depends_on = [
    azurerm_resource_group.example
  ]
}


  resource "azurerm_storage_account" "example" {
  name                     = "azureadtechstorage1245"
  resource_group_name      = azurerm_resource_group.example.name
  location                 = azurerm_resource_group.example.location
  account_tier             = "Standard"
  account_replication_type = "LRS" 
  
  
}
resource "azurerm_storage_container" "example" {
  name                  = "container"
  storage_account_name  = azurerm_storage_account.example.name
  container_access_type = "blob"
  depends_on = [ azurerm_storage_account.example ]
}
resource "azurerm_storage_blob" "example" {
  name                   = "IIS_Config.ps1"
  storage_account_name   = azurerm_storage_account.example.name
  storage_container_name = azurerm_storage_container.example.name
  type                   = "Block"
  source                 = "IIS_Config.ps1"
  depends_on = [ azurerm_storage_container.example ]
}


resource "azurerm_virtual_machine_extension" "example" {
  name                 = "vm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.example.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [ azurerm_storage_blob.example ]
  settings = <<SETTINGS
 {
  "fileUris" : ["https://azureadtechstorage1245.blob.core.windows.net/container/IIS_Config.ps1"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"
 }
SETTINGS


  
}

resource "azurerm_virtual_machine_extension" "example1" {
  name                 = "vm-extension"
  virtual_machine_id   = azurerm_windows_virtual_machine.example1.id
  publisher            = "Microsoft.Compute"
  type                 = "CustomScriptExtension"
  type_handler_version = "1.10"
  depends_on = [ azurerm_storage_blob.example ]
  settings = <<SETTINGS
 {
  "fileUris" : ["https://azureadtechstorage1245.blob.core.windows.net/container/IIS_Config.ps1"],
  "commandToExecute": "powershell -ExecutionPolicy Unrestricted -file IIS_Config.ps1"
 }
SETTINGS


  
}

resource "azurerm_network_security_group" "example" {
  name                = "nsg"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name

  security_rule {
    name                       = "Allow_HTTp"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
  security_rule {
    name                       = "RDP"
    priority                   = 200
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

 
}
resource "azurerm_subnet_network_security_group_association" "example" {
  subnet_id                 = azurerm_subnet.SubnetA.id
  network_security_group_id = azurerm_network_security_group.example.id
  depends_on = [ azurerm_network_security_group.example ]
}

resource "azurerm_public_ip" "load_ip" {
  name                = "load-ip"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  allocation_method   = "Static"
  sku="Standard"
}

resource "azurerm_lb" "app_balancer" {
  name                = "app-balancer"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku="Standard"
  sku_tier = "Regional"
  frontend_ip_configuration {
    name                 = "frontend-ip"
    public_ip_address_id = azurerm_public_ip.load_ip.id
  }

  depends_on=[
    azurerm_public_ip.load_ip
  ]
}

// Here we are defining the backend pool
resource "azurerm_lb_backend_address_pool" "PoolA" {
  loadbalancer_id = azurerm_lb.app_balancer.id
  name            = "PoolA"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm1_address" {
  name                    = "appvm1"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.example.id
  ip_address              = azurerm_network_interface.main.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}

resource "azurerm_lb_backend_address_pool_address" "appvm2_address" {
  name                    = "appvm2"
  backend_address_pool_id = azurerm_lb_backend_address_pool.PoolA.id
  virtual_network_id      = azurerm_virtual_network.example.id
  ip_address              = azurerm_network_interface.main1.private_ip_address
  depends_on=[
    azurerm_lb_backend_address_pool.PoolA
  ]
}


// Here we are defining the Health Probe
resource "azurerm_lb_probe" "ProbeA" {
  //resource_group_name = azurerm_resource_group.example.name
  loadbalancer_id     = azurerm_lb.app_balancer.id
  name                = "probeA"
  port                = 80
  protocol            =  "Tcp"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

// Here we are defining the Load Balancing Rule
resource "azurerm_lb_rule" "RuleA" {
  //resource_group_name            = azurerm_resource_group.app_grp.name
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "RuleA"
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "frontend-ip"
  backend_address_pool_ids = [ azurerm_lb_backend_address_pool.PoolA.id ]
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

// This is used for creating the NAT Rules

resource "azurerm_lb_nat_rule" "NATRuleA" {
  resource_group_name            = azurerm_resource_group.example.name
  loadbalancer_id                = azurerm_lb.app_balancer.id
  name                           = "RDPAccess"
  protocol                       = "Tcp"
  frontend_port                  = 3389
  backend_port                   = 3389
  frontend_ip_configuration_name = "frontend-ip"
  depends_on=[
    azurerm_lb.app_balancer
  ]
}

