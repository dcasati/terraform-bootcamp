data "azurerm_client_config" "current" {}

resource "azurerm_resource_group" "bootcamp" {
  name     = "my-resource-group"
  location = "West US"
}

resource "random_id" "server" {
  keepers = {
    ami_id = 1
  }

  byte_length = 8
}

resource "azurerm_key_vault" "bootcamp" {
  name                = "${format("%s%s", "kv", random_id.server.hex)}"
  location            = "${azurerm_resource_group.bootcamp.location}"
  resource_group_name = "${azurerm_resource_group.bootcamp.name}"
  tenant_id           = "${data.azurerm_client_config.current.tenant_id}"

  sku {
    name = "premium"
  }

  access_policy {
    tenant_id = "${data.azurerm_client_config.current.tenant_id}"
    object_id = "${data.azurerm_client_config.current.0.service_principal_object_id}"

    key_permissions = [
      "create",
      "get",
    ]

    secret_permissions = [
      "set",
      "get",
      "delete",
    ]
  }

  tags {
    environment = "Bootcamp"
  }
}

resource "azurerm_key_vault_secret" "bootcamp" {
  name       = "my-super-secret"
  value      = "I love coffee!"
  vault_uri  = "${azurerm_key_vault.bootcamp.vault_uri}"
  depends_on = ["azurerm_key_vault.bootcamp"]

  tags {
    environment = "Bootcamp"
  }
}
