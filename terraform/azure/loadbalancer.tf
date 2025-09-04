resource "random_string" "suffix" {
  length  = 5
  upper   = false
  special = false
}

resource "azurerm_public_ip" "lb" {
  name                = "${local.base_name}-lb-pip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"

  domain_name_label = trim(var.dns_label_prefix) != "" ? "${var.dns_label_prefix}-${random_string.suffix.result}" : null

  tags = local.common_tags
}

resource "azurerm_lb" "web" {
  name                = "${local.base_name}-lb"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  sku                 = "Standard"

  frontend_ip_configuration {
    name                 = "PublicFrontend"
    public_ip_address_id = azurerm_public_ip.lb.id
  }

  tags = local.common_tags
}

resource "azurerm_lb_backend_address_pool" "web" {
  name                = "${local.base_name}-bepool"
  loadbalancer_id     = azurerm_lb.web.id
}

resource "azurerm_lb_probe" "http" {
  name                = "http"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.web.id
  protocol            = "Tcp"
  port                = 80
}

resource "azurerm_lb_rule" "http" {
  name                           = "http"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.web.id
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  frontend_ip_configuration_name = "PublicFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.http.id
}

resource "azurerm_lb_probe" "https" {
  count               = var.enable_https ? 1 : 0
  name                = "https"
  resource_group_name = azurerm_resource_group.rg.name
  loadbalancer_id     = azurerm_lb.web.id
  protocol            = "Tcp"
  port                = 443
}

resource "azurerm_lb_rule" "https" {
  count                          = var.enable_https ? 1 : 0
  name                           = "https"
  resource_group_name            = azurerm_resource_group.rg.name
  loadbalancer_id                = azurerm_lb.web.id
  protocol                       = "Tcp"
  frontend_port                  = 443
  backend_port                   = 443
  frontend_ip_configuration_name = "PublicFrontend"
  backend_address_pool_ids       = [azurerm_lb_backend_address_pool.web.id]
  probe_id                       = azurerm_lb_probe.https[0].id
}