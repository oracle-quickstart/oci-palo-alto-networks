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

# ------ Create Web VCN IGW
resource "oci_core_internet_gateway" "web_igw" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.vcn_display_name}-igw"
  vcn_id         = oci_core_vcn.web[count.index].id
  enabled        = "true"
}

# ------ Create DRG
resource "oci_core_drg" "drg" {
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.vcn_display_name}-drg"
}

# ------ Attach DRG to Hub VCN
resource "oci_core_drg_attachment" "hub_drg_attachment" {
  drg_id             = oci_core_drg.drg.id
  # vcn_id             = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name       = "Firewall_VCN"
  drg_route_table_id = oci_core_drg_route_table.from_firewall_route_table.id

  network_details {
    id   = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
    type = "VCN"
    route_table_id = oci_core_route_table.vcn_ingress_route_table.0.id
  }
}

# ------ Attach DRG to Web Spoke VCN
resource "oci_core_drg_attachment" "web_drg_attachment" {
  drg_id             = oci_core_drg.drg.id
  vcn_id             = local.use_existing_network ? var.web_vcn_id : oci_core_vcn.web.0.id
  display_name       = "Web_VCN"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to DB Spoke VCN
resource "oci_core_drg_attachment" "db_drg_attachment" {
  drg_id             = oci_core_drg.drg.id
  vcn_id             = local.use_existing_network ? var.db_vcn_id : oci_core_vcn.db.0.id
  display_name       = "DB_VCN"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ DRG From Firewall Route Table
resource "oci_core_drg_route_table" "from_firewall_route_table" {
  drg_id                           = oci_core_drg.drg.id
  display_name                     = "From-Firewall"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
}

# ------ DRG to Firewall Route Table
resource "oci_core_drg_route_table" "to_firewall_route_table" {
  drg_id       = oci_core_drg.drg.id
  display_name = "To-Firewall"
}

# ------ Add DRG To Firewall Route Table Entry
resource "oci_core_drg_route_table_route_rule" "to_firewall_drg_route_table_route_rule" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id
  destination                = "0.0.0.0/0"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.hub_drg_attachment.id
}

# ---- DRG Route Import Distribution 
resource "oci_core_drg_route_distribution" "firewall_drg_route_distribution" {
  distribution_type = "IMPORT"
  drg_id            = oci_core_drg.drg.id
  display_name      = "Transit-Spokes"
}

# ---- DRG Route Import Distribution Statements - One
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_one" {
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.web_drg_attachment.id
  }
  priority = "1"
}

# ---- DRG Route Import Distribution Statements - Two 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_two" {
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.db_drg_attachment.id
  }
  priority = "2"
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

  route_rules {
    destination       = "172.16.0.0/16"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg.id
  }

  route_rules {
    destination       = "10.0.0.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg.id
  }

  route_rules {
    destination       = "10.0.1.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.drg.id
  }
}

# ------ Create LPG Hub Route Table
resource "oci_core_route_table" "vcn_ingress_route_table" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  vcn_id         = oci_core_vcn.hub[count.index].id
  display_name   = "VCNINGRESSRouteTable"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.untrust_subnet_private_ips.private_ips[0].id
  }

  route_rules {
    destination       = "10.0.0.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.untrust_subnet_private_ips.private_ips[0].id
  }

  route_rules {
    destination       = "10.0.1.0/24"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.untrust_subnet_private_ips.private_ips[0].id
  }

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
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = data.oci_core_private_ips.untrust_subnet_private_ips.private_ips[0].id
  }

  depends_on = [
    # oci_network_load_balancer_network_load_balancer.internal_nlb,
  ]
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
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "false"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
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
  security_list_ids          = [data.oci_core_security_lists.allow_all_security.security_lists[0].id]
  prohibit_public_ip_on_vnic = "false"

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Create Web VCN
resource "oci_core_vcn" "web" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.web_vcn_cidr_block
  dns_label      = var.web_vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.web_vcn_display_name
}

# ------ Create Web Route Table and Associate to Web LPG
resource "oci_core_default_route_table" "web_default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.web[count.index].default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.web_igw[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }

  route_rules {
    network_entity_id = oci_core_drg.drg.id
    destination       = "10.0.1.0/24"
    destination_type  = "CIDR_BLOCK"
  }

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
  security_list_ids          = [data.oci_core_security_lists.allow_all_security_web.security_lists[0].id]

  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Create DB VCN
resource "oci_core_vcn" "db" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.db_vcn_cidr_block
  dns_label      = var.db_vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.db_vcn_display_name
}

# ------ Create DB Route Table and Associate to DB LPG
resource "oci_core_default_route_table" "db_default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.db[count.index].default_route_table_id
  route_rules {
    network_entity_id = oci_core_drg.drg.id
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
  security_list_ids          = [data.oci_core_security_lists.allow_all_security_db.security_lists[0].id]

  depends_on = [
    oci_core_security_list.allow_all_security_db,
  ]
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "allow_all_security" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "allow_all_security_web" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.web.0.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "allow_all_security_db" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.db.0.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }

  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}