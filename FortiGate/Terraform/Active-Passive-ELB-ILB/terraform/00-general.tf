##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################

# Prefix for all resources created for this deployment in Microsoft Azure
variable "PREFIX" {
  description = "Added name to each deployed resource"
}

variable "LOCATION" {
  description = "Azure region"
}

variable "USERNAME" {
}

variable "PASSWORD" {
}

variable "STATE" {
  type    = string
  default = "prd"
}
##############################################################################################################
# FortiGate configuration script
##############################################################################################################

variable "custom_template_file" {
  type = string
  default = ""
  description = "Path to a custom tpl file to replace the customdata.tpl"
}

variable "fgt_ipsec_psk" {
  type        = string
  description = "Password of ipsec vpn"
  sensitive   = true
}

variable "fgt_radius_psk" {
  type        = string
  description = "Password of radius"
  sensitive   = true
}

variable "fgt_analyzer_psk" {
  type        = string
  description = "Password of analyzer"
  sensitive   = true
}

##############################################################################################################
# FortiGate license type
##############################################################################################################

variable "FGT_IMAGE_SKU" {
  description = "Azure Marketplace default image sku hourly (PAYG 'fortinet_fg-vm_payg_20190624') or byol (Bring your own license 'fortinet_fg-vm')"
  default     = "fortinet_fg-vm_payg_20190624"
}

variable "FGT_VERSION" {
  description = "FortiGate version by default the 'latest' available version in the Azure Marketplace is selected"
  default     = "latest"
}

variable "FGT_BYOL_LICENSE_FILE_A" {
  default = ""
}

variable "FGT_BYOL_LICENSE_FILE_B" {
  default = ""
}

variable "FGT_BYOL_FLEXVM_LICENSE_FILE_A" {
  default = ""
}

variable "FGT_BYOL_FLEXVM_LICENSE_FILE_B" {
  default = ""
}

variable "FGT_SSH_PUBLIC_KEY_FILE" {
  default = ""
}

##############################################################################################################
# Accelerated Networking
# Only supported on specific VM series and CPU count: D/DSv2, D/DSv3, E/ESv3, F/FS, FSv2, and Ms/Mms
# https://azure.microsoft.com/en-us/blog/maximize-your-vm-s-performance-with-accelerated-networking-now-generally-available-for-both-windows-and-linux/
##############################################################################################################
variable "FGT_ACCELERATED_NETWORKING" {
  description = "Enables Accelerated Networking for the network interfaces of the FortiGate"
  default     = "true"
}

variable "FGT_CONFIG_HA" {
  description = "Automatically configures the FGCP HA configuration using cloudinit"
  default     = "true"
}

##############################################################################################################
# Deployment in Microsoft Azure
##############################################################################################################

terraform {
  required_version = ">= 0.12"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">=2.0.0"
    }
  }
}

provider "azurerm" {
  features {}
}

##############################################################################################################
# Accept the Terms license for the FortiGate Marketplace image
# This is a one-time agreement that needs to be accepted per subscription
# https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/resources/marketplace_agreement
##############################################################################################################
resource "azurerm_marketplace_agreement" "fortinet" {
  publisher = "fortinet"
  offer     = "fortinet_fortigate-vm_v5"
  plan      = var.FGT_IMAGE_SKU
}

##############################################################################################################
# Static variables
##############################################################################################################

variable "vnet" {
  description = ""
  default     = "172.16.136.0/22"
}

variable "subnet" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.136.0/26"   # External
    "2" = "172.16.136.64/26"  # Internal
    "3" = "172.16.136.128/26" # HASYNC
    "4" = "172.16.136.192/26" # MGMT
    "5" = "172.16.137.0/24"   # Protected a
    "6" = "172.16.138.0/24"   # Protected b
  }
}

variable "vnet_internal_route" {
  type = string
  default = "172.16.136.0/22"
  description = "Used in firewall as routing table for internal nets"
}

variable "subnetmask" {
  type        = map(string)
  description = ""

  default = {
    "1" = "26" # External
    "2" = "26" # Internal
    "3" = "26" # HASYNC
    "4" = "26" # MGMT
    "5" = "24" # Protected a
    "6" = "24" # Protected b
  }
}

variable "fgt_ipaddress_a" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.136.5"   # External
    "2" = "172.16.136.69"  # Internal
    "3" = "172.16.136.133" # HASYNC
    "4" = "172.16.136.197" # MGMT
  }
}

variable "fgt_ipaddress_b" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.136.6"   # External
    "2" = "172.16.136.70"  # Internal
    "3" = "172.16.136.134" # HASYNC
    "4" = "172.16.136.198" # MGMT
  }
}

variable "gateway_ipaddress" {
  type        = map(string)
  description = ""

  default = {
    "1" = "172.16.136.1"   # External
    "2" = "172.16.136.65"  # Internal
    "3" = "172.16.136.133" # HASYNC
    "4" = "172.16.136.193" # MGMT
  }
}

variable "lb_internal_ipaddress" {
  description = ""
  type = string
  default = "172.16.136.68"
}

variable "lbe_rules_disable_outbound_snat" {
  type = bool
  default = false
}

variable "fgt_vmsize" {
  default = "Standard_F4s"
}

variable "fortinet_tags" {
  type = map(string)
  default = {
    publisher : "Fortinet",
    template : "Active-Passive-ELB-ILB",
    provider : "7EB3B02F-50E5-4A3E-8CB8-2E12925831AP"
  }
}

variable "use_management_pips" {
  type = bool
  default = true 
}

##############################################################################################################
# Network Names
##############################################################################################################

variable "vnet_name" {
  type    = string
  default = ""
}

variable "subnet_names" {
  type = map(string)
  default = {
    "1" = "" # External
    "2" = "" # Internal
    "3" = "" # HASYNC
    "4" = "" # MGMT
    "5" = "" # Protected a
    "6" = "" # Protected b
  }
}

variable "route_table_names" {
  type = map(string)
  default = {
    "protecteda" = ""
    "protectedb" = ""
  }
}

##############################################################################################################
# FortiGate Names
##############################################################################################################

variable "avset_name" {
  type    = string
  default = ""
}

variable "nsg_name" {
  type    = string
  default = ""
}

variable "elb_config_names" {
  type = map(string)
  default = {
    "name"                 = ""
    "pip_name"             = ""
    "frontend_ip_name"     = ""
    "backend_address_pool" = ""
    "lb_probe_name"        = ""
  }
}

variable "ilb_config_names" {
  type = map(string)
  default = {
    "name"                 = ""
    "frontend_ip_name"     = ""
    "backend_address_pool" = ""
    "lb_probe_name"        = ""
  }
}

variable "nic_names" {
  type = map(string)
  default = {
    "fgtaifcext"    = ""
    "fgtaifcint"    = ""
    "fgtaifchasync" = ""
    "fgtaifcmgmt"   = ""

    "fgtbifcext"    = ""
    "fgtbifcint"    = ""
    "fgtbifchasync" = ""
    "fgtbifcmgmt"   = ""
  }
}

variable "vm_names" {
  type = map(string)
  default = {
    "fgtavm" = ""
    "fgtbvm" = ""
  }
}

variable "disk_names" {
  type = map(string)
  default = {
    "fgtaosdisk"   = ""
    "fgtadatadisk" = ""

    "fgtbosdisk"   = ""
    "fgtbdatadisk" = ""
  }
}

variable "mgmt_pip_names" {
  type = map(string)
  default = {
    "fgta" = ""
    "fgtb" = ""
  }
}

##############################################################################################################
# Resource Group
##############################################################################################################

variable "resource_group_name" {
  type    = string
  default = ""
}

resource "azurerm_resource_group" "resourcegroup" {
  name     = coalesce(var.resource_group_name, "${var.PREFIX}-RG")
  location = var.LOCATION
}

##############################################################################################################
