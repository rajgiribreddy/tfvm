resource "azurerm_resource_group" "main" {
  name     = "VM-RG"
  location = "eastus"
}
resource "azurerm_virtual_network" "main" {
  name                = "VM-VNET"
  address_space       = ["14.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
}

resource "azurerm_subnet" "subnet" {
  name                 = "VM-SUBNET"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefix       = "14.0.0.0/24"
}
resource "azurerm_public_ip" "main" {
  name                = "VM-PIP"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  allocation_method   = "Dynamic"
  tags = {
    environment = "Prouction"
  }
}
resource "azurerm_network_interface" "main" {
  name                = "VM-NIC"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  ip_configuration {
    name                          = "VM-IPNAME"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.main.id
  }
}
resource "azurerm_network_security_group" "main" {
  name     = "VM-NSG"
  location = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  security_rule = {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "RDP"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "3389"
    destination_address_prefix = "*"

  }
}
resource "azurerm_network_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.main.id
  network_security_group_id = azurerm_network_security_group.main.id
}

resource "azurerm_windows_virtual_machine" "main" {
  name                = "VM1"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  size                = "Standard_DS1_V2"
  admin_username      = "adminuser"
  admin_password      = "Azure@123456"
  network_interface_ids = [
    azurerm_network_interface.main.id,
  ]

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}
