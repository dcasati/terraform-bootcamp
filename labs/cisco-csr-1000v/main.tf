#provider "azurerm" {
#  subscription_id = "REPLACE-WITH-YOUR-SUBSCRIPTION-ID"
#  client_id       = "REPLACE-WITH-YOUR-CLIENT-ID"
#  client_secret   = "REPLACE-WITH-YOUR-CLIENT-SECRET"
#  tenant_id       = "REPLACE-WITH-YOUR-TENANT-ID"
#}

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

# ************************** AVAILABILITY SET ****************************** #

resource "azurerm_availability_set" "test" {
  name                = "acceptanceTestAvailabilitySet1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  # magic numbers are based on the Marketplace defaults from Cisco
  platform_update_domain_count = "20"
  platform_fault_domain_count = "2"

  tags {
    environment = "Bootcamp"
  }
}

# ***************************** VNET / SUBNET ****************************** #
resource "azurerm_virtual_network" "vnet" {
  name                = "${azurerm_resource_group.rg.name}-vnet"
  location            = "${var.location}"
  address_space       = ["${var.address_space}"]
  resource_group_name = "${azurerm_resource_group.rg.name}"
}

resource "azurerm_subnet" "subnet_1" {
  name                 = "${azurerm_resource_group.rg.name}-subnet_1"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_1_prefix}"
}

resource "azurerm_subnet" "subnet_2" {
  name                 = "${azurerm_resource_group.rg.name}-subnet_2"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_2_prefix}"
}

resource "azurerm_subnet" "subnet_3" {
  name                 = "${azurerm_resource_group.rg.name}-subnet_3"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_3_prefix}"
}

resource "azurerm_subnet" "subnet_4" {
  name                 = "${azurerm_resource_group.rg.name}-subnet_4"
  virtual_network_name = "${azurerm_virtual_network.vnet.name}"
  resource_group_name  = "${azurerm_resource_group.rg.name}"
  address_prefix       = "${var.subnet_4_prefix}"
}


# ********************** NETWORK SECURITY GROUP **************************** #
resource "azurerm_network_security_group" "mgmt-nsg" {
  name                = "${azurerm_resource_group.rg.name}-mgmt-nsg"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  location            = "${azurerm_resource_group.rg.location}"

  security_rule {
    name                       = "allow-ssh"
    description                = "Allow SSH"
    priority                   = 1000
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "Internet"
    destination_address_prefix = "*"
  }

  tags {
    environment = "Bootcamp"
  }
}


# ************************** NETWORK INTERFACES **************************** #
# For the Create Cisco CSR 1000v - XE 16.x with 4 NICs we will create 4 NICs
# and 4 subnets.
#
# Subnet      Addr. Space   NIC 
# ------------------------------
# Subnet 1    10.1.1.0/24   nic1 (Public IP will be attached here)
# Subnet 2    10.1.2.0/24   nic2
# Subnet 3    10.1.3.0/24   nic3
# Subnet 4    10.1.4.0/24   nic4

# ******************************* NIC 1 ************************************ #

resource "azurerm_network_interface" "nic1" {
  name                = "${azurerm_resource_group.rg.name}-nic1"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"
  network_security_group_id = "${azurerm_network_security_group.mgmt-nsg.id}"

  ip_configuration {
    name                          = "${var.hostname}-ipconfig-nic1"
    subnet_id                     = "${azurerm_subnet.subnet_1.id}"
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = "${azurerm_public_ip.pip.id}"
  }

  tags {
    environment = "Bootcamp"
  }
}

# ************************** PUBLIC IP ADDRESSES **************************** #
resource "azurerm_public_ip" "pip" {
  name                         = "${azurerm_resource_group.rg.name}-pip"
  location                     = "${var.location}"
  resource_group_name          = "${azurerm_resource_group.rg.name}"
  allocation_method 	       = "Dynamic"
  domain_name_label            = "${var.hostname}${random_integer.random_int.result}"

  tags {
    environment = "Bootcamp"
  }
}

# ******************************* NIC 2, 3, 4 ************************************ #
# needs a better way to tackle this.

resource "azurerm_network_interface" "nic2" {
  name                = "${azurerm_resource_group.rg.name}-nic2"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.hostname}-ipconfig-nic2"
    subnet_id                     = "${azurerm_subnet.subnet_2.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags {
    environment = "Bootcamp"
  }
}

resource "azurerm_network_interface" "nic3" {
  name                = "${azurerm_resource_group.rg.name}-nic3"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.hostname}-ipconfig-nic3"
    subnet_id                     = "${azurerm_subnet.subnet_3.id}"
    private_ip_address_allocation = "Dynamic"
  }

  tags {
    environment = "Bootcamp"
  }
}

resource "azurerm_network_interface" "nic4" {
  name                = "${azurerm_resource_group.rg.name}-nic4"
  location            = "${var.location}"
  resource_group_name = "${azurerm_resource_group.rg.name}"

  ip_configuration {
    name                          = "${var.hostname}-ipconfig-nic4"
    subnet_id                     = "${azurerm_subnet.subnet_4.id}"
    private_ip_address_allocation = "Dynamic"
  }

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
  network_interface_ids = [
    "${azurerm_network_interface.nic1.id}",
    "${azurerm_network_interface.nic2.id}",
    "${azurerm_network_interface.nic3.id}",
    "${azurerm_network_interface.nic4.id}"
    ]
  primary_network_interface_id =     "${azurerm_network_interface.nic1.id}"

  storage_image_reference {
    publisher = "${var.image_publisher}"
    offer     = "${var.image_offer}"
    sku       = "${var.image_sku}"
    version   = "${var.image_version}"
  }

  # For Marketplace offers
  plan {
    name = "${var.image_sku}"
    publisher = "${var.image_publisher}"
    product = "${var.image_offer}"
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
  }

  os_profile_linux_config {
    disable_password_authentication = true
    ssh_keys {
      path = "/home/${var.admin_username}/.ssh/authorized_keys"
      key_data = "${file("~/.ssh/id_rsa.pub")}"
    }
  }

  boot_diagnostics {
    enabled     = true
    storage_uri = "${azurerm_storage_account.stor.primary_blob_endpoint}"
  }

  tags {
    environment = "Bootcamp"
  }
}
