#provider "azurerm" {
#  subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
#  client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
#  client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"
#  tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
#}

# Locate the existing custom/golden image
data "azurerm_image" "search" {
  name                = "${var.image_name}"
  resource_group_name = "${var.image_resource_group}"
}

output "image_id" {
  value = "${data.azurerm_image.search.id}"
}

# randomize some things
resource "random_integer" "random_int" {
  min = 100
  max = 999
}

# ************************** Terraform Bootcamp **************************** #
resource "azurerm_resource_group" "rg" {
  name     = "${var.resource_group}"
  location = "${var.location}"
}

# ***************************** VNET / SUBNET ****************************** #
resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "mgmt-subnet" {
  name                 = "${azurerm_resource_group.rg.name}-mgmt-subnet"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.mgmt-subnet_prefix}"
}

# ********************** NETWORK SECURITY GROUP **************************** #
resource "azurerm_network_security_group" "mgmt-nsg" {
  name                = "${azurerm_resource_group.rg.name}-mgmt-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "allow-RDP"
    description                = "Allow RDP"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "3389"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Bootcamp"
  }
}

# ************************** NETWORK INTERFACES **************************** #
resource "azurerm_network_interface" "nic" {
  name                      = "${azurerm_resource_group.rg.name}-nic"
  location                  = "${var.location}"
  resource_group_name       = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.mgmt-nsg.id}"

  ip_configuration {
    name                          = "${var.hostname}-ipconfig"
    subnet_id                     = "${azurerm_subnet.mgmt-subnet.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }

  tags {
    environment = "Bootcamp"
  }
}

# ************************** PUBLIC IP ADDRESSES **************************** #
resource "azurerm_public_ip" "pip" {
  name                = "${azurerm_resource_group.rg.name}-pip"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  allocation_method   = "Dynamic"
  domain_name_label   = "${var.hostname}${random_integer.random_int.result}"

  tags {
    environment = "Bootcamp"
  }
}

# ***************************** STORAGE ACCOUNT **************************** #
resource "azurerm_storage_account" "stor" {
  name                     = "${var.hostname}stor"
  location                 = "${var.location}"
  resource_group_name      = "${azurerm_resource_group.rg.name}"
  account_tier             = "${var.storage_account_tier}"
  account_replication_type = "${var.storage_replication_type}"
}

resource "azurerm_managed_disk" "datadisk" {
  name                 = "${var.hostname}-datadisk"
  location             = "${var.location}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  storage_account_type = "Standard_LRS"
  create_option        = "Empty"
  disk_size_gb         = "1023"
}

# ***************************** VIRTUAL MACHINE **************************** #
resource "azurerm_virtual_machine" "vm" {
  name                  = "${azurerm_resource_group.rg.name}-vm"
  location              = "${var.location}"
  resource_group_name   = "${azurerm_resource_group.rg.name}"
  vm_size               = "${var.vm_size}"
  network_interface_ids = ["${azurerm_network_interface.nic.id}"]

  storage_image_reference {
    id = "${data.azurerm_image.search.id}"
  }

  storage_os_disk {
    name              = "${var.hostname}-osdisk"
    managed_disk_type = "Standard_LRS"
    caching           = "ReadWrite"
    create_option     = "FromImage"
  }

  storage_data_disk {
    name              = "${var.hostname}-datadisk"
    managed_disk_id   = "${azurerm_managed_disk.datadisk.id}"
    managed_disk_type = "Standard_LRS"
    disk_size_gb      = "1023"
    create_option     = "Attach"
    lun               = 0
  }

  os_profile {
    computer_name  = "${var.hostname}"
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
  }

  os_profile_windows_config {
    enable_automatic_upgrades = true
    provision_vm_agent        = true
  }
}
