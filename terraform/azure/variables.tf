variable "name_prefix" {
  description = "A short prefix used to name all resources (e.g., project or org name)."
  type        = string
}

variable "environment" {
  description = "Deployment environment (e.g., dev, staging, prod)."
  type        = string
  default     = "dev"
}

variable "location" {
  description = "Azure region to deploy resources into."
  type        = string
  default     = "eastus"
}

variable "address_space" {
  description = "Address space for the virtual network."
  type        = list(string)
  default     = ["10.10.0.0/16"]
}

variable "web_subnet_cidr" {
  description = "CIDR for the web subnet where VMSS instances will live."
  type        = string
  default     = "10.10.1.0/24"
}

variable "bastion_subnet_cidr" {
  description = "CIDR for the Bastion subnet (required if create_bastion = true). Must be at least /27."
  type        = string
  default     = "10.10.100.0/27"
}

variable "create_bastion" {
  description = "Whether to provision Azure Bastion for secure SSH access (recommended)."
  type        = bool
  default     = true
}

variable "admin_username" {
  description = "Admin username for the Linux VMs."
  type        = string
  default     = "azureuser"
}

variable "ssh_public_key" {
  description = "Public SSH key to access the VMs (required when create_bastion = false or for break-glass SSH)."
  type        = string
}

variable "allowed_ssh_cidrs" {
  description = "Optional list of CIDR ranges allowed to SSH directly to VMs (not recommended; use Bastion). If empty, no direct SSH rule will be created."
  type        = list(string)
  default     = []
}

variable "vm_size" {
  description = "VM size for the web server VM Scale Set."
  type        = string
  default     = "Standard_B2s"
}

variable "instance_count" {
  description = "Number of VM instances in the scale set."
  type        = number
  default     = 2
}

variable "dns_label_prefix" {
  description = "Optional prefix for the public IP DNS label (generates &lt;prefix&gt;-&lt;rand&gt;.&lt;region&gt;.cloudapp.azure.com). Leave empty to skip DNS."
  type        = string
  default     = ""
}

variable "enable_https" {
  description = "Open port 443 on the load balancer and VMs (certificate management not included)."
  type        = bool
  default     = false
}

variable "zones" {
  description = "Optional availability zones to use (if supported in the region). Example: [\"1\", \"2\", \"3\"]. Leave empty for no zone pinning."
  type        = list(string)
  default     = []
}

variable "tags" {
  description = "A map of tags to apply to all resources."
  type        = map(string)
  default     = {}
}