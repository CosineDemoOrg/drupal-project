locals {
  vmss_name = "${local.base_name}-web-vmss"
}

resource "azurerm_linux_virtual_machine_scale_set" "web" {
  name                    = local.vmss_name
  resource_group_name     = azurerm_resource_group.rg.name
  location                = azurerm_resource_group.rg.location
  sku                     = var.vm_size
  instances               = var.instance_count
  admin_username          = var.admin_username
  computer_name_prefix    = "webvm"

  # Use zones if provided (some regions may not support all zones)
  zones = length(var.zones) > 0 ? var.zones : null

  admin_ssh_key {
    username   = var.admin_username
    public_key = var.ssh_public_key
  }

  identity {
    type = "SystemAssigned"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }

  upgrade_mode = "Rolling"

  # Cloud-init to install and configure Nginx + PHP-FPM
  custom_data = base64encode(
    templatefile("${path.module}/cloud-init.tpl", {
      server_name = trim(var.dns_label_prefix) != "" ? azurerm_public_ip.lb.fqdn : "_"
      enable_https = var.enable_https
    })
  )

  network_interface {
    name    = "${local.vmss_name}-nic"
    primary = true

    ip_configuration {
      name                                   = "internal"
      primary                                = true
      subnet_id                               = azurerm_subnet.web.id
      load_balancer_backend_address_pool_ids = [azurerm_lb_backend_address_pool.web.id]
    }
  }

  boot_diagnostics {
    storage_account_uri = null
  }

  tags = local.common_tags
}