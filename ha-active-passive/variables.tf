## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl


#Variables declared in this file must be declared in the marketplace.yaml

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {
}

variable "region" {
}

############################
#  Marketplace Image      #
############################

variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = true
}

variable "mp_listing_id" {
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaai7wszf2tvojm2zw5epmx6ynaivbbe6zpye2kts344zg6u2jujbta"
  description = "Marketplace Listing OCID"
}

variable "mp_listing_resource_id" {
  default     = "ocid1.image.oc1..aaaaaaaa6enkdji2lard54gp5uycngvtkcblk22zaawh7obaibe7bmcxcalq"
  description = "Marketplace Listing Image OCID"
}

variable "mp_listing_resource_version" {
  default     = "10.0.3"
  description = "Marketplace Listing Package/Resource Version"
}

############################
#  Compute Configuration   #
############################

variable "vm_display_name" {
  description = "Instance Name"
  default     = "firewall-ha"
}

variable "vm_display_name_web" {
  description = "Instance Name"
  default     = "web-app"
}

variable "vm_display_name_db" {
  description = "Instance Name"
  default     = "db-app"
}

variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.4" //4 cores
}

variable "spoke_vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.2" //2 cores
}

variable "vm_flex_shape_ocpus" {
  description = "Flex Shape OCPUs"
  default     = 4
}

variable "spoke_vm_flex_shape_ocpus" {
  description = "Spoke VMs Flex Shape OCPUs"
  default     = 4
}
variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain"
}

variable "availability_domain_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

variable "ssh_public_key" {
  description = "SSH Public Key String"
}

variable "instance_launch_options_network_type" {
  description = "NIC Attachment Type"
  default     = "PARAVIRTUALIZED"
}

############################
#  Network Configuration   #
############################

variable "network_strategy" {
  default = "Create New VCN and Subnet"
}

variable "vcn_id" {
  default = ""
}

variable "vcn_display_name" {
  description = "VCN Name"
  default     = "firewall-vcn"
}

variable "vcn_cidr_block" {
  description = "VCN CIDR"
  default     = "192.168.0.0/16"
}

variable "vcn_dns_label" {
  description = "VCN DNS Label"
  default     = "ha"
}

variable "subnet_span" {
  description = "Choose between regional and AD specific subnets"
  default     = "Regional Subnet"
}

variable "mangement_subnet_id" {
  default = ""
}

variable "mangement_subnet_display_name" {
  description = "Management Subnet Name"
  default     = "management-subnet"
}

variable "mangement_subnet_cidr_block" {
  description = "Management Subnet CIDR"
  default     = "192.168.0.0/24"
}

variable "mangement_subnet_dns_label" {
  description = "Management Subnet DNS Label"
  default     = "management"
}

variable "trust_subnet_id" {
  default = ""
}

variable "trust_subnet_display_name" {
  description = "Trust Subnet Name"
  default     = "trust-subnet"
}

variable "trust_subnet_cidr_block" {
  description = "Trust Subnet CIDR"
  default     = "192.168.2.0/24"
}

variable "trust_subnet_dns_label" {
  description = "Trust Subnet DNS Label"
  default     = "trust"
}

variable "untrust_subnet_id" {
  default = ""
}

variable "untrust_subnet_display_name" {
  description = "PAN Untrust Subnet Name"
  default     = "untrust-subnet"
}

variable "untrust_subnet_cidr_block" {
  description = "PAN Untrust Subnet CIDR"
  default     = "192.168.1.0/24"
}

variable "untrust_subnet_dns_label" {
  description = "Untrust Subnet DNS Label"
  default     = "untrust"
}

variable "ha2_subnet_id" {
  default = ""
}

variable "ha2_subnet_display_name" {
  description = "HA2 Subnet Name"
  default     = "ha2-subnet"
}

variable "ha2_subnet_cidr_block" {
  description = "HA2 Subnet CIDR"
  default     = "192.168.30.0/24"
}

variable "ha2_subnet_dns_label" {
  description = "HA2 Subnet DNS Label"
  default     = "ha2"
}

variable "dynamic_group_description" {
  description = "Dynamic Group to Support PAN HA"
  default     = "Dynamic Group to Support PAN HA"
}

variable "dynamic_group_name" {
  description = "Dynamic Group Name"
  default     = "pan-ha-dynamic-group"
}

variable "dynamic_group_policy_description" {
  description = "Dynamic Group Policy to allow PAN HA floating IP switch"
  default     = "Dynamic Group Policy for PAN HA"
}

variable "dynamic_group_policy_name" {
  description = "Dynamic Group Policy PAN"
  default     = "pan-ha-dynamic-group-policy"
}

variable "web_vcn_cidr_block" {
  description = "Web Spoke VCN CIDR Block"
  default     = "10.0.0.0/24"
}

variable "web_vcn_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "web"
}

variable "web_vcn_display_name" {
  description = "Web Spoke VCN Display Name"
  default     = "web-vcn"
}

variable "web_transit_subnet_id" {
  default = ""
}

variable "web_transit_subnet_cidr_block" {
  description = "Web Spoke VCN Private Subnet"
  default     = "10.0.0.0/25"
}

variable "web_transit_subnet_display_name" {
  description = "Web Spoke VCN Private Subnet Display Name"
  default     = "web_private-subnet"
}

variable "web_transit_subnet_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "webtransit"
}

variable "web_lb_subnet_id" {
  default = ""
}

variable "web_lb_subnet_cidr_block" {
  description = "Web Spoke VCN Loadbalancer Subnet"
  default     = "10.0.0.128/25"
}

variable "web_lb_subnet_display_name" {
  description = "Web Spoke VCN LB Subnet Display Name"
  default     = "web_lb-subnet"
}

variable "web_lb_subnet_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "weblb"
}

variable "backend_port" {
  description = "Web Load Balancer Backend Port"
  default     = 80
}

variable "db_vcn_cidr_block" {
  description = "DB Spoke VCN CIDR Block"
  default     = "10.0.1.0/24"
}

variable "db_vcn_dns_label" {
  description = "DB Spoke VCN DNS Label"
  default     = "db"
}

variable "db_vcn_display_name" {
  description = "DB Spoke VCN Display Name"
  default     = "db-vcn"
}

variable "db_transit_subnet_id" {
  default = ""
}

variable "db_transit_subnet_cidr_block" {
  description = "DB Spoke VCN Private Subnet"
  default     = "10.0.1.0/25"
}

variable "db_transit_subnet_display_name" {
  description = "DB Spoke VCN Private Subnet Display Name"
  default     = "db_private-subnet"
}

variable "db_transit_subnet_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "dbtransit"
}

############################
# Additional Configuration #
############################

variable "compute_compartment_ocid" {
  description = "Compartment where Compute and Marketplace subscription resources will be created"
}

variable "network_compartment_ocid" {
  description = "Compartment where Network resources will be created"
}

variable "nsg_whitelist_ip" {
  description = "Network Security Groups - Whitelisted CIDR block for ingress communication: Enter 0.0.0.0/0 or <your IP>/32"
  default     = "0.0.0.0/0"
}

variable "nsg_display_name" {
  description = "Network Security Groups - Name"
  default     = "cluster-security-group"
}

variable "web_nsg_display_name" {
  description = "Network Security Groups - Web"
  default     = "web-security-group"
}

variable "db_nsg_display_name" {
  description = "Network Security Groups - App"
  default     = "db-security-group"
}


variable "public_routetable_display_name" {
  description = "Public route table Name"
  default     = "UntrustRouteTable"
}

variable "private_routetable_display_name" {
  description = "Private route table Name"
  default     = "TrustRouteTable"
}

variable "lpg_routetable_display_name" {
  description = "LPG route table Name"
  default     = "LPGRouteTable"
}

variable "drg_routetable_display_name" {
  description = "DRG route table Name"
  default     = "DRGRouteTable"
}

variable "sgw_routetable_display_name" {
  description = "SGW route table Name"
  default     = "SGWRouteTable"
}

variable "use_existing_ip" {
  description = "Use an existing permanent public ip"
  default     = "Create new IP"
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type"
  default     = "ha"
}

variable "template_version" {
  description = "Template version"
  default     = "20200724"
}

######################
#    Enum Values     #   
######################
variable "network_strategy_enum" {
  type = map
  default = {
    CREATE_NEW_VCN_SUBNET   = "Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET = "Use Existing VCN and Subnet"
  }
}

variable "subnet_type_enum" {
  type = map
  default = {
    transit_subnet    = "Private Subnet"
    MANAGEMENT_SUBENT = "Public Subnet"
  }
}

variable "nsg_config_enum" {
  type = map
  default = {
    BLOCK_ALL_PORTS = "Block all ports"
    OPEN_ALL_PORTS  = "Open all ports"
    CUSTOMIZE       = "Customize ports - Post deployment"
  }
}
