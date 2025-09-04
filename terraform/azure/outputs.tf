output "resource_group_name" {
  description = "Name of the resource group."
  value       = azurerm_resource_group.rg.name
}

output "location" {
  description = "Azure region."
  value       = azurerm_resource_group.rg.location
}

output "lb_public_ip" {
  description = "Public IP address of the load balancer."
  value       = azurerm_public_ip.lb.ip_address
}

output "lb_fqdn" {
  description = "FQDN of the load balancer public IP (if a DNS label prefix was provided)."
  value       = azurerm_public_ip.lb.fqdn
}

output "bastion_id" {
  description = "Azure Bastion resource ID (if created)."
  value       = var.create_bastion ? azurerm_bastion_host.bastion[0].id : null
}

output "vmss_name" {
  description = "Name of the VM Scale Set."
  value       = azurerm_linux_virtual_machine_scale_set.web.name
}