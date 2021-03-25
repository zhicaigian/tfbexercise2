resource "azurerm_resource_group" "rg" {
  name     = "${var.environment}-var.rgName"
  location = var.rgLocation
}

#virtual network/VPC
resource "azurerm_virtual_network" "vnet" {
  name                = "${var.environment}-myTFVnet"
  address_space       = var.vpc_cidr
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#subnet
resource "azurerm_subnet" "subnet" {
  name                 = "${var.environment}-myTFSubnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = var.public_subnets
}

#network security group for our resource
resource "azurerm_network_security_group" "nsg" {
  name                = "${var.environment}-myTFNetworkSecurityGroup"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

#firewall rules for web port 80 tcp
resource "azurerm_network_security_rule" "web" {
  name                        = "${var.environment}-WebPort80Tcp"
  priority                    = 1001
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "80"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name

}

#firewall rules for web port 22 ssh
resource "azurerm_network_security_rule" "ssh" {
  name                        = "${var.environment}-SSHAccess"
  priority                    = 1002
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "22"
  source_address_prefix       = "*"
  destination_address_prefix  = "*"
  network_security_group_name = azurerm_network_security_group.nsg.name
  resource_group_name         = azurerm_resource_group.rg.name
}

#public ip address
resource "azurerm_public_ip" "publicIP" {
  name                = "${var.environment}-myTFPublicIP"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Dynamic"
}

#network interface card configuration
resource "azurerm_network_interface" "nic" {
  name                = "${var.environment}-myTFNIC"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  ip_configuration {
    name                          = "${var.environment}-myNICConfig"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.subnet.id
    public_ip_address_id          = azurerm_public_ip.publicIP.id
  }
}

#linux vm 
resource "azurerm_virtual_machine" "vm" {
  name                = "${var.environment}-myTFVM"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  #a vm needs NIC so..
  network_interface_ids = [azurerm_network_interface.nic.id]

  #WARNING: DO NOT USE THIS IN PRODUCTION UNLESS IN CONFIG
  delete_os_disk_on_termination    = true
  delete_data_disks_on_termination = true

  #vm size
  vm_size = "Standard_B1ls"

  #os profile
  os_profile {
    computer_name  = "${var.environment}-azureVMNAME"
    admin_username = var.admin_username
    admin_password = var.admin_password
    custom_data    = file("${path.module}/../web/files/web_bootstrap.sh")
  }

  os_profile_linux_config {
    disable_password_authentication = false
  }

  #we need a storage
  storage_os_disk {
    name              = "${var.environment}-myOSDisk"
    create_option     = "FromImage"
    caching           = "ReadWrite"
    managed_disk_type = "Standard_LRS"
  }

  #we os info for our storage
  storage_image_reference {
    # for reference, refer to az cli command:
    # az vm image list --output table
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "18.04-LTS"
    version   = "latest"
  } 
} //end of vm resource


# Use this data source to access information about a set of existing Public IP Addresses.
# Data sources allow data to be fetched or computed for use elsewhere in Terraform configuration.
data "azurerm_public_ip" "ip" {
  name                = azurerm_public_ip.publicIP.name
  resource_group_name = azurerm_resource_group.rg.name
  depends_on = [
    azurerm_virtual_machine.vm
  ]
}

