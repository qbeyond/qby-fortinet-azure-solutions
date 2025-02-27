##############################################################################################################
#
# FortiGate Active/Passive High Availability with Azure Standard Load Balancer - External and Internal
# Terraform deployment template for Microsoft Azure
#
##############################################################################################################
#
# Output summary of deployment
#
##############################################################################################################

data "template_file" "summary" {
  template = file("${path.module}/summary.tpl")

  vars = {
    username                        = var.USERNAME
    location                        = var.LOCATION
    elb_ipaddress                   = data.azurerm_public_ip.elbpip.ip_address
    fgt_a_private_ip_address_ext    = azurerm_network_interface.fgtaifcext.private_ip_address
    fgt_a_private_ip_address_int    = azurerm_network_interface.fgtaifcint.private_ip_address
    fgt_a_private_ip_address_hasync = azurerm_network_interface.fgtaifchasync.private_ip_address
    fgt_a_private_ip_address_mgmt   = azurerm_network_interface.fgtaifcmgmt.private_ip_address
    fgt_a_public_ip_address         = var.use_management_pips ? data.azurerm_public_ip.fgtamgmtpip[0].ip_address : ""
    fgt_b_private_ip_address_ext    = azurerm_network_interface.fgtbifcext.private_ip_address
    fgt_b_private_ip_address_int    = azurerm_network_interface.fgtbifcint.private_ip_address
    fgt_b_private_ip_address_hasync = azurerm_network_interface.fgtbifchasync.private_ip_address
    fgt_b_private_ip_address_mgmt   = azurerm_network_interface.fgtbifcmgmt.private_ip_address
    fgt_b_public_ip_address         = var.use_management_pips ? data.azurerm_public_ip.fgtbmgmtpip[0].ip_address : ""
  }
}

output "deployment_summary" {
  value = data.template_file.summary.rendered
}

output "fortivm" {
  value = {
    fgtavm = azurerm_virtual_machine.fgtavm
    fgtbvm = azurerm_virtual_machine.fgtbvm
  }
}

output "load_balancer" {
  value = {
    elb = azurerm_lb.elb
    elb_probe = azurerm_lb_probe.elbprobe
    elb_backend_address_pool = azurerm_lb_backend_address_pool.elbbackend
  }
}

output "network" {
  value = {
    vnet    = azurerm_virtual_network.vnet
    subnet1 = azurerm_subnet.subnet1
    subnet2 = azurerm_subnet.subnet2
    subnet3 = azurerm_subnet.subnet3
    subnet4 = azurerm_subnet.subnet4
    subnet5 = azurerm_subnet.subnet5
    subnet6 = azurerm_subnet.subnet6
  }
}

output "nsg" {
  value = azurerm_network_security_group.fgtnsg
}