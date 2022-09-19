variable "resourcegroup" {
  type        = list(any)
  description = "Resource Group used for all resources."
  default     = ["az104-07-rg0", "az104-07-rg1"]
}

variable "resourcegroup1" {
  type        = string
  description = "Resource Group used for all resources."
  default     = "az104-07-rg0"
}

variable "resourcegroup2" {
  type        = string
  description = "Resource Group used for all resources."
  default     = "az104-07-rg1"
}

variable "size" {
  type        = string
  description = "Virtual Machine size, Default: Standard_DS1_v2"
  default     = "Standard_DS1_v2"
}

variable "storage_account_type" {
  type        = string
  description = "Virtual Machine Disk type, Default: Standard_LRS"
  default     = "Standard_LRS"
}

variable "name" {
  type        = string
  description = "Virtual Machine Name."
  default     = "WIN2k19"
}

variable "nic" {
  type        = string
  description = "Virtual Network Interface Name."
  default     = "az104-07-vm0"
}

variable "vnet" {
  type        = string
  description = "Virtual network Name used for all resources"
  default     = "az104-05-vnet0"
}

variable "source_image_reference_publisher" {
  type        = string
  description = "Virtual Machine Publisher, Default: MicrosoftWindowsServer"
  default     = "MicrosoftWindowsServer"
}

variable "source_image_reference_offer" {
  type        = string
  description = "Virtual Machine Offer, Default: WindowsServer"
  default     = "WindowsServer"
}

variable "source_image_reference_sku" {
  type        = string
  description = "Virtual Machine Sku, Default: 2019-Datacenter"
  default     = "2019-Datacenter"
}

variable "source_image_reference_version" {
  type        = string
  description = "Virtual Machine Version, Default: latest"
  default     = "latest"
}

variable "vnetaddress_space" {
  type        = string
  description = "Address space used for all resources. Recommend subnet config /16"
  default     = "10.70.0.0/22"
}

variable "subnet" {
  type        = string
  description = "Subnet Network Name used for all resources"
  default     = "Subnet0"
}

variable "subnetaddress_prefixes" {
  type        = string
  description = "Subnet network used for all resources. Recommend subnet config /24"
  default     = "10.70.0.0/24"
}

variable "publicip" {
  type        = string
  description = "The public IP assin to the new VM."
  default     = "az104-07"
}

variable "publicip_sku" {
  type        = string
  description = "The public IP sku: Default Basic"
  default     = "Basic"
}


variable "nsg" {
  type        = string
  description = "Network Security Group Name used for all resources"
  default     = "az104-07-nsg"
}

variable "user" {
  type        = string
  description = "User Name to connect on the VM."
  default     = "lab.azuser"
}

variable "password" {
  type        = string
  description = "password to connect on the VM."
  default     = "Q1w2e3r4t5%"
}

variable "location" {
  type        = string
  description = "Azure region used for all resources"
  default     = "eastus2"
}

variable "storage_accountname" {
  type        = string
  description = "Description the storage account name"
  default     = "az10407rg1rsp1906202210h"
}

variable "storage_container" {
  type        = string
  description = "Description the storage account name"
  default     = "az104-07-container"
}

variable "storage_share" {
  type        = string
  description = "Description the storage share name"
  default     = "az104-07"
}

variable "storage_share_directory" {
  type        = string
  description = "Description the storage share name"
  default     = "az104-07-share"
}

variable "storage_blob" {
  type        = string
  description = "Description the storage share name"
  default     = "az104-07-blob"
}

variable "license" {
  type        = string
  description = "Description the storage share name"
  default     = "license"
}
