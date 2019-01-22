variable "resource_group" {
  description = "The name of the resource group in which to create the virtual network."
}

variable "rg_prefix" {
  description = "The shortened abbreviation to represent your resource group that will go on the front of some resources."
  default     = "rg"
}

variable "hostname" {
  description = "VM name referenced also in storage-related names."
}

variable "dns_name" {
  description = " Label for the Domain Name. Will be used to make up the FQDN. If a domain name label is specified, an A DNS record is created for the public IP in the Microsoft Azure DNS system."
}

variable "location" {
  description = "The location/region where the virtual network is created. Changing this forces a new resource to be created."
  default     = "westus2"
}

variable "virtual_network_name" {
  description = "The name for the virtual network."
  default     = "vnet"
}

variable "address_space" {
  description = "The address space that is used by the virtual network. You can supply more than one address space. Changing this forces a new resource to be created."
  default     = "10.1.0.0/16"
}

variable "subnet_1_prefix" {
  description = "The address prefix to use for the subnet1."
  default     = "10.1.1.0/24"
}

variable "subnet_2_prefix" {
  description = "The address prefix to use for the subnet2."
  default     = "10.1.2.0/24"
}

variable "subnet_3_prefix" {
  description = "The address prefix to use for the subnet3."
  default     = "10.1.3.0/24"
}

variable "subnet_4_prefix" {
  description = "The address prefix to use for the subnet4."
  default     = "10.1.4.0/24"
}

variable "storage_account_tier" {
  description = "Defines the Tier of storage account to be created. Valid options are Standard and Premium."
  default     = "Standard"
}

variable "storage_replication_type" {
  description = "Defines the Replication Type to use for this storage account. Valid options include LRS, GRS etc."
  default     = "LRS"
}

variable "vm_size" {
  description = "Specifies the size of the virtual machine."
  default     = "Standard_DS3_v2"
}

variable "image_publisher" {
  description = "name of the publisher of the image (az vm image list)"
  default     = "cisco"
}

variable "image_offer" {
  description = "the name of the offer (az vm image list-offers -l westus -p Cisco -o table)"
  default     = "cisco-csr-1000v"
}

variable "image_sku" {
  description = "image sku to apply (az vm image list). You can retrieve a full list with:i az vm image list-skus -l westus -p Cisco -o table -f cisco-csr-1000v"
  default     = "16_4"
}

variable "image_version" {
  description = "version of the image to apply (az vm image list)"
  default     = "16.4.120180717"
}

variable "admin_username" {
  description = "administrator user name"
  default     = "azureuser"
}

variable "ssh_key_data" {
  default     = "~/.ssh/id_rsa.pub"
}
