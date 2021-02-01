## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# ------ Create HUB VCN
resource "oci_core_vcn" "hub" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.vcn_cidr_block
  dns_label      = var.vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.vcn_display_name
}

# ------ Create IGW
resource "oci_core_internet_gateway" "igw" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.vcn_display_name}-igw"
  vcn_id         = oci_core_vcn.hub[count.index].id
  enabled        = "true"
}

# ------ Create DRG
resource "oci_core_drg" "drg" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.vcn_display_name}-drg"
}


# ------ Default Routing Table for Hub VCN 
resource "oci_core_default_route_table" "default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.hub[count.index].default_route_table_id
  display_name               = "DefaultRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}

# ------ Default Routing Table for Hub VCN 
resource "oci_core_route_table" "untrust_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.public_routetable_display_name

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.igw[count.index].id
  }
}

# ------ Create LPG Hub Route Table
resource "oci_core_route_table" "lpg_hub_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.lpg_routetable_display_name

  route_rules {
    network_entity_id = oci_core_private_ip.cluster_trust_ip.id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  depends_on = [
    oci_core_private_ip.cluster_trust_ip,
  ]
}

# ------ Create DRG Hub Route Table
resource "oci_core_route_table" "drg_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.drg_routetable_display_name
}

# ------ Get All Services Data Value 
data "oci_core_services" "all_services" {
  filter {
    name   = "name"
    values = ["All .* Services In Oracle Services Network"]
    regex  = true
  }
}

# ------ Create Hub Service Gateway (Hub VCN)
resource "oci_core_service_gateway" "hub_service_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  services {
    service_id = data.oci_core_services.all_services.services[0]["id"]
  }
  display_name   = "hubServiceGateway"
  route_table_id = oci_core_route_table.service_gw_route_table_transit_routing[count.index].id
}

# ------ Get Hub Service Gateway from Gateways (Hub VCN)
data "oci_core_service_gateways" "hub_service_gateways" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  state          = "AVAILABLE"
  vcn_id         = oci_core_vcn.hub[count.index].id
}

# ------ Associate Emptry Route Tables to Service Gateway on Hub VCN Floating IP
resource "oci_core_route_table" "service_gw_route_table_transit_routing" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = var.sgw_routetable_display_name

  route_rules {
    network_entity_id = oci_core_private_ip.cluster_trust_ip.id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }
}

# ------ Peering connections to the Web from Hub (Hub VCN)
resource "oci_core_local_peering_gateway" "hub_web_local_peering_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = "hub_web"
  peer_id        = oci_core_local_peering_gateway.web_hub_local_peering_gateway[count.index].id
  route_table_id = oci_core_route_table.lpg_hub_route_table[count.index].id
}

# ------ Peering connections to the DB from Hub (Hub VCN)
resource "oci_core_local_peering_gateway" "hub_db_local_peering_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = "hub_db"
  peer_id        = oci_core_local_peering_gateway.db_hub_local_peering_gateway[count.index].id
  route_table_id = oci_core_route_table.lpg_hub_route_table[count.index].id
}

# ------ Create Hub VCN Public subnet
resource "oci_core_subnet" "mangement_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.mangement_subnet_cidr_block
  display_name               = var.mangement_subnet_display_name
  route_table_id             = oci_core_vcn.hub[count.index].default_route_table_id
  dns_label                  = var.mangement_subnet_dns_label
  prohibit_public_ip_on_vnic = "false"
}

# ------ Create Hub VCN Trust subnet
resource "oci_core_subnet" "trust_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.trust_subnet_cidr_block
  display_name               = var.trust_subnet_display_name
  dns_label                  = var.trust_subnet_dns_label
  prohibit_public_ip_on_vnic = "true"

}

# ------ Update Route Table for Trust Subnet
resource "oci_core_route_table_attachment" "update_trust_route_table" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
  route_table_id = oci_core_route_table.trust_route_table[count.index].id
}

# ------ Create Hub VCN PAN Internet subnet
resource "oci_core_subnet" "untrust_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.untrust_subnet_cidr_block
  display_name               = var.untrust_subnet_display_name
  route_table_id             = oci_core_route_table.untrust_route_table[count.index].id
  dns_label                  = var.untrust_subnet_dns_label
  prohibit_public_ip_on_vnic = "false"
}

# ------ Create Hub VCN PAN HA First subnet
resource "oci_core_subnet" "ha2_subnet" {
  count                      = local.use_existing_network ? 0 : 1
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.hub[count.index].id
  cidr_block                 = var.ha2_subnet_cidr_block
  display_name               = var.ha2_subnet_display_name
  route_table_id             = oci_core_vcn.hub[count.index].default_route_table_id
  dns_label                  = var.ha2_subnet_dns_label
  prohibit_public_ip_on_vnic = "true"
}

# ------ Create Cluster Trust Floating IP (Hub VCN)
resource "oci_core_private_ip" "cluster_trust_ip" {
  vnic_id      = data.oci_core_vnic_attachments.trust_attachments.vnic_attachments.0.vnic_id
  display_name = "firewall_trust_secondary_private"
}

# ------ Create Cluster Untrust Floating IP (Hub VCN)
resource "oci_core_private_ip" "cluster_untrust_ip" {
  vnic_id      = data.oci_core_vnic_attachments.untrust_attachments.vnic_attachments.0.vnic_id
  display_name = "firewall_untrust_secondary_private"
}

# frontend cluster ip 
resource "oci_core_public_ip" "cluster_untrust_public_ip" {
  count          = (var.use_existing_ip != "Create new IP") ? 0 : 1
  compartment_id = var.network_compartment_ocid

  lifetime      = "RESERVED"
  private_ip_id = oci_core_private_ip.cluster_untrust_ip.id
}

# ------ Create route table for backend to point to backend cluster ip (Hub VCN)
resource "oci_core_route_table" "trust_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub[0].id
  display_name   = var.private_routetable_display_name

  route_rules {
    network_entity_id = oci_core_private_ip.cluster_trust_ip.id

    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
  }

  route_rules {
    destination       = "10.0.0.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.hub_web_local_peering_gateway[count.index].id
  }

  route_rules {
    destination       = "10.0.1.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_local_peering_gateway.hub_db_local_peering_gateway[count.index].id
  }

  route_rules {
    destination_type  = "SERVICE_CIDR_BLOCK"
    destination       = data.oci_core_services.all_services.services[0]["cidr_block"]
    network_entity_id = oci_core_service_gateway.hub_service_gateway[count.index].id
  }

  depends_on = [
    oci_core_private_ip.cluster_trust_ip,
    oci_core_local_peering_gateway.hub_web_local_peering_gateway,
    oci_core_local_peering_gateway.hub_db_local_peering_gateway
  ]
}

# ------ Add Trust route table to Trust subnet (Hub VCN)
resource "oci_core_route_table_attachment" "trust_route_table_attachment" {
  count          = local.use_existing_network ? 0 : 1
  subnet_id      = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id
  route_table_id = oci_core_route_table.trust_route_table[count.index].id
}

# ------ Create Web VCN
resource "oci_core_vcn" "web" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.web_vcn_cidr_block
  dns_label      = var.web_vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.web_vcn_display_name
}

# ------ Create Web VCN LPG(Local Peering Gateway)
resource "oci_core_local_peering_gateway" "web_hub_local_peering_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.web[count.index].id
  display_name   = "LPG WebApp Spoke"
}

# ------ Create Web Route Table and Associate to Web LPG
resource "oci_core_default_route_table" "web_default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.web[count.index].default_route_table_id
  route_rules {
    network_entity_id = oci_core_local_peering_gateway.web_hub_local_peering_gateway[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# ------ Add Web Private Subnet to Web VCN
resource "oci_core_subnet" "web_private-subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.web_transit_subnet_cidr_block
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.web[count.index].id
  display_name               = var.web_transit_subnet_display_name
  dns_label                  = var.web_transit_subnet_dns_label
  prohibit_public_ip_on_vnic = true
}

# ------ Add Web Load Balancer Subnet to Web VCN
resource "oci_core_subnet" "web_lb-subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.web_lb_subnet_cidr_block
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.web[count.index].id
  display_name               = var.web_lb_subnet_display_name
  dns_label                  = var.web_lb_subnet_dns_label
  prohibit_public_ip_on_vnic = false
}

# ------ Create DB VCN
resource "oci_core_vcn" "db" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.db_vcn_cidr_block
  dns_label      = var.db_vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.db_vcn_display_name
}

# ------ Create DB VCN LPG(Local Peering Gateway)
resource "oci_core_local_peering_gateway" "db_hub_local_peering_gateway" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.db[count.index].id
  display_name   = "LPG_Database_Spoke"
}

# ------ Create DB Route Table and Associate to DB LPG
resource "oci_core_default_route_table" "db_default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.db[count.index].default_route_table_id
  route_rules {
    network_entity_id = oci_core_local_peering_gateway.db_hub_local_peering_gateway[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# ------ Add DB Private Subnet to DB VCN
resource "oci_core_subnet" "db_private-subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.db_transit_subnet_cidr_block
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.db[count.index].id
  display_name               = var.db_transit_subnet_display_name
  dns_label                  = var.db_transit_subnet_dns_label
  prohibit_public_ip_on_vnic = true
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "default_security_list" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
}