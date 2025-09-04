Azure VM + Nginx Terraform Scaffold
===================================

This Terraform configuration deploys a production‑grade baseline on Azure:
- Resource Group
- Virtual Network + subnets (web, optional Bastion)
- Network Security Group with least‑privilege inbound rules
- Public Standard Load Balancer (HTTP, optional HTTPS passthrough)
- Linux VM Scale Set (Ubuntu 22.04) behind the LB
- Cloud‑init to install and configure Nginx + PHP‑FPM
- Optional Azure Bastion for secure SSH access (recommended)

Notes
-----
- This is a scaffold. It provisions compute and networking to run a PHP/Nginx app. It does not include database/storage/caching. Integrate Azure Database for MySQL or Postgres, Azure Files/Disks, Redis, etc., as needed.
- HTTPS is exposed at the LB and Nginx layers (port 443) if enabled, but certificate provisioning/renewal is not included. Consider using Azure Application Gateway + Key Vault or integrate certbot/Key Vault in cloud‑init/CM tooling.
- Remote Terraform state is recommended. Configure the azurerm backend via backend config before `terraform init`.

Prerequisites
-------------
- Terraform >= 1.5
- Azure CLI (`az`) authenticated to your subscription
- An SSH public key

Quick Start
-----------
1) Configure backend (recommended)

Create or reuse a Storage Account and container for state (one‑time):
- Resource Group: rg-tfstate
- Storage Account: sttfstate&lt;unique&gt;
- Container: tfstate

Then either:
- Provide `-backend-config` flags on `terraform init`, or
- Create a `backend.hcl` file:

  storage_account_name = "sttfstate&lt;unique&gt;"
  container_name       = "tfstate"
  key                  = "myapp-dev.tfstate"
  resource_group_name  = "rg-tfstate"

2) Initialize, plan, and apply

  cd terraform/azure
  cp terraform.tfvars.example terraform.tfvars
  # edit terraform.tfvars to suit your environment

  # init (with backend)
  terraform init -backend-config=../backend.hcl

  # or init without a backend (local state)
  # terraform init

  terraform plan
  terraform apply

3) Access
- Public endpoint:
  - IP: output `lb_public_ip`
  - FQDN (if `dns_label_prefix` provided): output `lb_fqdn`
- SSH:
  - Recommended: use Azure Bastion (set `create_bastion = true`). Open the VMSS instance via the Azure Portal -> Bastion.
  - Direct SSH: not recommended; if you must, set `allowed_ssh_cidrs` and access via per‑instance private IP through a jump host or add an inbound NAT pool to the LB.

Configuration
-------------
Edit `terraform.tfvars`:
- name_prefix: short project prefix (e.g. "myapp")
- environment: dev|staging|prod
- location: Azure region (e.g. eastus)
- address_space, web_subnet_cidr: VNet/Subnet CIDRs
- create_bastion: true|false
- ssh_public_key: your SSH public key
- vm_size, instance_count, zones: sizing and HA
- dns_label_prefix: optional public DNS label (produces &lt;label&gt;-&lt;rand&gt;.&lt;region&gt;.cloudapp.azure.com)
- enable_https: expose 443 (certificate management not included)
- tags: map of tags

What gets deployed
------------------
- Standard Public IP with optional DNS label and Standard Load Balancer
- Backend pool + health probes (HTTP 80) and LB rules (80; optional 443 passthrough)
- Ubuntu 22.04 VMSS joined to the backend pool
- Cloud‑init that:
  - Installs Nginx + PHP‑FPM and common PHP extensions
  - Creates a basic Nginx vhost pointing to /var/www/app/public
  - Places a simple index.php health page
  - Enables and restarts services

Next steps (app deployment)
---------------------------
- Replace cloud‑init with a stronger provisioning approach:
  - Build a custom image (Packer) with Nginx/PHP preinstalled
  - Use CM tooling (Ansible/Chef/Puppet) or an Azure VM Extension to deploy your app
  - Mount Azure Files or attach managed disks for persistent storage
- Add a managed database (Azure Database for MySQL/Postgres) and secure connectivity
- Add Key Vault for secrets/certificates
- Consider Application Gateway (WAF) for TLS termination and L7 routing

Destroy
-------
  terraform destroy