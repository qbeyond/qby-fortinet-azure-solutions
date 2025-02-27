# Azure China - Active/Passive High Available FortiGate pair with external and internal Azure Standard Load Balancer

## Introduction

This design is adapted from the Azure Global ARM template [here](../../Active-Passive-ELB-ILB/README.md). The main difference between both is the deployment changes needed for deployment in the Azure China region.

## Design

In Microsoft Azure, you can deploy an active/passive pair of FortiGate VMs that communicate with each other and the Azure fabric. This FortiGate setup will receive the traffic to be inspected traffic using user defined routing (UDR) and public IPs. You can send all or specific traffic that needs inspection, going to/coming from on-prem networks or public internet by adapting the UDR routing.

This Azure ARM template will automatically deploy a full working environment containing the following components.

  - 2 FortiGate firewall's in an active/passive deployment
  - 1 external Azure Standard Load Balancer for communication with internet
  - 1 internal Azure Standard Load Balancer to receive all internal traffic and forwarding towards Azure Gateways connecting ExpressRoute or Azure VPN's
  - 1 VNET with 2 protected subnets and 4 subnets required for the FortiGate deployment (external, internal, ha mgmt and ha sync). If using an existing vnet, it must already have 5 subnets
  - 3 public IPs. The first public IP is for cluster access to/through the active FortiGate.  The other two PIPs are for Management access
  - User Defined Routes (UDR) for the protected subnets

![active/passive design](../../Active-Passive-ELB-ILB/images/fgt-ap.png)

This ARM template can also be used to extend or customized based on your requirements. Additional subnets besides the one's mentioned above are not automatically generated. By adapting the ARM templates you can add additional subnets which preferably require their own routing tables.

## How to deploy

The FortiGate solution can be deployed using the Azure Portal or Azure CLI. There are 4 variables needed to complete kickstart the deployment. The deploy.sh script will ask them automatically. When you deploy the ARM template the Azure Portal will request the variables as a requirement.

  - PREFIX : This prefix will be added to each of the resources created by the templates for easy of use, manageability and visibility.
  - LOCATION : This is the Azure region where the deployment will be deployed
  - USERNAME : The username used to login to the FortiGate GUI and SSH management UI.
  - PASSWORD : The password used for the FortiGate GUI and SSH management UI.

### Azure Portal

<a href="https://portal.azure.cn/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FActive-Passive-ELB-ILB%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>
<a href="http://armviz.io/#/?load=https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions$2Fmain%2FFortiGate%2FAzureChina%2FActive-Passive-ELB-ILB%2Fazuredeploy.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/visualizebutton.svg?sanitize=true"/>
</a>

<br/>
Azure Portal Wizard:
<a href="https://portal.azure.cn/#create/Microsoft.Template/uri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FAzureChina%2FActive-Passive-ELB-ILB%2Fazuredeploy.json/createUiDefinitionUri/https%3A%2F%2Fraw.githubusercontent.com%2F40net-cloud%2Ffortinet-azure-solutions%2Fmain%2FFortiGate%2FActive-Passive-ELB-ILB%2FcreateUiDefinition.json" target="_blank">
  <img src="https://raw.githubusercontent.com/Azure/azure-quickstart-templates/master/1-CONTRIBUTION-GUIDE/images/deploytoazure.svg?sanitize=true"/>
</a>

### Azure CLI

For Microsoft Azure there is a second option by using the Azure Cloud Shell. The Azure Cloud Shell is an in-browser CLI that contains all tools for deployment into Microsoft Azure. It is accesible via the Azure Portal or directly via [https://shell.azure.cn/](https://shell.azure.cn). You can copy and past the below one-liner to get start with your deployment.
To deploy via Azure Cloud Shell you can connect via the Azure Portal or directly to [https://shell.azure.cn/](https://shell.azure.cn/).

- Login into the Azure Cloud Shell
- Run the following command in the Azure Cloud:

`cd ~/clouddrive/ && wget -qO- https://github.com/40net-cloud/fortinet-azure-solutions/archive/main.tar.gz | tar zxf - && cd ~/clouddrive/fortinet-azure-solutions-main/FortiGate/AzureChina/Active-Passive-ELB-ILB/ && ./deploy.sh`

- The script will ask you a few questions to bootstrap a full deployment.

![Azure Cloud Shell](images/azure-cloud-shell.png)

After deployment you will be shown the IP address of all deployed components. Both FortiGate VMs are accessible using the public management IPs using HTTPS on port 443 and SSH on port 22.

## Requirements and limitations

The ARM template deploys different resources and it is required to have the access rights and quota in your Microsoft Azure subscription to deploy the resources.

- The template will deploy Standard F4s VMs for this architecture. Other VM instances are supported as well with a minimum of 4 NICs. A list can be found [here](https://docs.fortinet.com/document/fortigate/6.4.0/azure-cookbook/562841/instance-type-support)
- Licenses for Fortigate
  - BYOL: A demo license can be made available via your Fortinet partner or on our website. These can be injected during deployment or added after deployment. Purchased licenses need to be registered on the [Fortinet support site] (http://support.fortinet.com). Download the .lic file after registration. Note, these files may not work until 30 minutes after it's initial creation.
  - PAYG or OnDemand: These licenses are automatically generated during the deployment of the FortiGate systems.
- The password provided during deployment must need password complexity rules from Microsoft Azure:
  - It must be 12 characters or longer
  - It needs to contain characters from at least 3 of the following groups: uppercase characters, lowercase characters, numbers, and special characters excluding '\' or '-'
- The terms for the FortiGate PAYG or BYOL image in the Azure Marketplace needs to be accepted once before usage. This is done automatically during deployment via the Azure Portal. For the Azure CLI the commands below need to be run before the first deployment in a subscription.
  - BYOL
`az vm image accept-terms --publisher fortinet --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm`
  - PAYG
`az vm image accept-terms --publisher fortinet --offer fortinet_fortigate-vm_v5 --plan fortinet_fg-vm_payg_20190624`

## FortiGate configuration

The FortiGate VMs need a specific configuration to match the deployed environment. This configuration can be injected during provisioning or afterwards via the different options including GUI, CLI, FortiManager or REST API.

- [Default configuration using this template](doc/config-provisioning.md)
- [High Availability probe](doc/config-ha.md)
- [Cloud-init](doc/config-cloud-init.md)
- [Inbound connections](doc/config-inbound-connections.md)
- [Outbound connections](doc/config-outbound-connections.md)
  - [NAT considerations: 1-to-1 and 1-to-many](doc/config-outbound-nat-considerations.md)
- [East-West connections](doc/config-east-west-connections.md)

### Fabric Connector

The FortiGate-VM uses [Managed Identities](https://docs.microsoft.com/en-us/azure/active-directory/managed-identities-azure-resources/) for the SDN Fabric Connector. A SDN Fabric Connector is created automatically during deployment. After deployment, it is required apply the 'Reader' role to the Azure Subscription you want to resolve Azure Resources from. More information can be found on the [Fortinet Documentation Libary](https://docs.fortinet.com/vm/azure/fortigate/7.0/azure-administration-guide/7.0.0/236610/creating-a-fabric-connector-using-a-managed-identity).

## Troubleshooting

You can find a troubleshooting guide for this setup [here](doc/troubleshooting.md)

## Support
Fortinet-provided scripts in this and other GitHub projects do not fall under the regular Fortinet technical support scope and are not supported by FortiCare Support Services.
For direct issues, please refer to the [Issues](https://github.com/fortinet/azure-templates/issues) tab of this GitHub project.
For other questions related to this project, contact [github@fortinet.com](mailto:github@fortinet.com).

## License
[License](LICENSE) © Fortinet Technologies. All rights reserved.
