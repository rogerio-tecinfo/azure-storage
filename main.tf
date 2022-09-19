# Create resource group
resource "azurerm_resource_group" "resourcegroup" {
  count    = 2
  name     = element(var.resourcegroup, count.index)
  location = var.location
}

# Create virtual network
resource "azurerm_virtual_network" "vnet" {
  name                = var.vnet
  address_space       = [var.vnetaddress_space]
  location            = var.location
  resource_group_name = var.resourcegroup1
  depends_on          = [azurerm_resource_group.resourcegroup]
}

# Create subnet
resource "azurerm_subnet" "subnet" {
  name                 = var.subnet
  resource_group_name  = var.resourcegroup1
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = [var.subnetaddress_prefixes]
  depends_on           = [azurerm_virtual_network.vnet]
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
  name                = var.publicip
  location            = var.location
  resource_group_name = var.resourcegroup1
  allocation_method   = "Dynamic"
  sku                 = var.publicip_sku
  depends_on          = [azurerm_subnet.subnet]

}

# Create Network Security Group and rule to open port 3389 to internet.
resource "azurerm_network_security_group" "nsg" {
  name                = var.nsg
  location            = var.location
  resource_group_name = var.resourcegroup1

  security_rule {
    name                       = "RDP"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "33389"
    destination_port_range     = "3389"
    source_address_prefix      = "*"
    destination_address_prefix = "10.70.0.4"
  }
  depends_on = [azurerm_public_ip.publicip]
}

# Create network interface with Internal and Public IP
resource "azurerm_network_interface" "nic" {
  name                = var.nic
  location            = var.location
  resource_group_name = var.resourcegroup1

  ip_configuration {
    name                          = "${var.name}nicconfiguration"
    subnet_id                     = azurerm_subnet.subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.publicip.id
  }
  depends_on = [azurerm_public_ip.publicip]
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "connectnic" {
  network_interface_id      = azurerm_network_interface.nic.id
  network_security_group_id = azurerm_network_security_group.nsg.id
  depends_on = [azurerm_network_interface.nic, azurerm_network_security_group.nsg,
  azurerm_public_ip.publicip]
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "name" {
  name                  = var.name
  location              = var.location
  resource_group_name   = var.resourcegroup1
  network_interface_ids = [azurerm_network_interface.nic.id]
  size                  = var.size

  os_disk {
    name                 = "${var.name}_osdisk"
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.source_image_reference_publisher
    offer     = var.source_image_reference_offer
    sku       = var.source_image_reference_sku
    version   = var.source_image_reference_version
  }

  computer_name  = var.name
  admin_username = var.user
  admin_password = var.password
  #    disable_password_authentication = true

  depends_on = [azurerm_network_interface_security_group_association.connectnic]

}

# Create Storage Account
resource "azurerm_storage_account" "storage_accountname" {
  name                     = var.storage_accountname
  resource_group_name      = var.resourcegroup2
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind             = "StorageV2"
  depends_on               = [azurerm_resource_group.resourcegroup]
  tags = {
    environment = "staging"
  }
}

# Create Storage Container
resource "azurerm_storage_container" "storage_container" {
  name                  = var.storage_container
  storage_account_name  = var.storage_accountname
  container_access_type = "blob"
  depends_on            = [azurerm_storage_account.storage_accountname]
}

# Create Storage Blob
resource "azurerm_storage_blob" "storage_blob" {
  name                   = var.license
  storage_account_name   = var.storage_accountname
  storage_container_name = var.storage_container
  type                   = "Block"
  source                 = "LICENSE"
  depends_on             = [azurerm_storage_account.storage_accountname]
}

data "azurerm_storage_account_blob_container_sas" "blob_container_sas" {
  connection_string = azurerm_storage_account.storage_accountname.primary_connection_string
  container_name    = var.storage_container
  https_only        = true
  start             = "2022-09-08T00:00:00Z"
  expiry            = "2022-10-21T00:00:00Z"
  permissions {
    read   = true
    add    = false
    create = false
    write  = true
    delete = true
    list   = true
  }

}
output "sas_url_query_string" {
  value     = data.azurerm_storage_account_blob_container_sas.blob_container_sas.sas
  sensitive = true

}

# Create Storage Share 
resource "azurerm_storage_share" "storage_share" {
  name                 = var.storage_share
  storage_account_name = var.storage_accountname
  quota                = 50
  depends_on           = [azurerm_storage_account.storage_accountname]
}

# Create Storage Share Directory
resource "azurerm_storage_share_directory" "storage_share_directory" {
  name                 = var.storage_share_directory
  share_name           = var.storage_share
  storage_account_name = var.storage_accountname
  depends_on           = [azurerm_storage_share.storage_share]
}
