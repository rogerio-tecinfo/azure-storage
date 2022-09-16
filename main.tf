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

}

# Create subnet
resource "azurerm_subnet" "subnet" {
    name                 = var.subnet
    resource_group_name  = var.resourcegroup1
    virtual_network_name = azurerm_virtual_network.vnet.name
    address_prefixes       = [var.subnetaddress_prefixes]
}

# Create public IPs
resource "azurerm_public_ip" "publicip" {
    name                         = var.publicip
    location                     = var.location
    resource_group_name          = var.resourcegroup1
    allocation_method            = "Dynamic"
    sku                          = var.publicip_sku

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
        source_port_range          = "*"
        destination_port_range     = "3389"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

}

# Create network interface with Internal and Public IP
resource "azurerm_network_interface" "nic" {
    name                      = var.nic
    location                  = var.location
    resource_group_name       = var.resourcegroup1

    ip_configuration {
        name                          = "${var.name}nicconfiguration"
        subnet_id                     = azurerm_subnet.subnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.publicip.id
    }

}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "connectnic" {
    network_interface_id      = azurerm_network_interface.nic.id
    network_security_group_id = azurerm_network_security_group.nsg.id
}

# Create virtual machine
resource "azurerm_windows_virtual_machine" "name" {
    name                  = var.name
    location              = var.location
    resource_group_name   = var.resourcegroup1
    network_interface_ids = [azurerm_network_interface.nic.id]
    size                  = var.size

    os_disk {
        name              = "${var.name}_osdisk"
        caching           = "ReadWrite"
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
    
    depends_on = [
    azurerm_resource_group.resourcegroup,
  ]

}

# Create Storage Account
resource "azurerm_storage_account" "storage_accountname" {
  name                     = var.storage_accountname
  resource_group_name      = var.resourcegroup2
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  account_kind = "BlobStorage"

  tags = {
    environment = "staging"
  }
}

# Create Storage Container
resource "azurerm_storage_container" "storage_container" {
  name                  = var.storage_container
  storage_account_name  = var.storage_accountname
  container_access_type = "private"
}

# Create Storage Share 
resource "azurerm_storage_share" "storage_share" {
  name                 = var.storage_share
  storage_account_name = var.storage_accountname
  quota                = 50 
  acl {
    id = "MTIzNDU2Nzg5MDEyMzQ1Njc4OTAxMjM0NTY3ODkwMTI"

    access_policy {
      permissions = "rwdl"
      start       = "2022-09-16T08:00:00.0000000Z"
      expiry      = "2019-10-16T10:00:00.0000000Z"
    }
  }
}

# Create Storage Share Directory
resource "azurerm_storage_share_directory" "storage_share_directory" {
  name                 = var.storage_share_directory
  share_name           = var.storage_share
  storage_account_name = var.storage_accountname
}
