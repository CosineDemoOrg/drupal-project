locals {
  common_tags = merge(
    {
      "env"     = var.environment
      "project" = var.name_prefix
      "owner"   = "terraform"
    },
    var.tags
  )

  base_name = "${var.name_prefix}-${var.environment}"
}

resource "azurerm_resource_group" "rg" {
  name     = "${local.base_name}-rg"
  location = var.location
  tags     = local.common_tags
}