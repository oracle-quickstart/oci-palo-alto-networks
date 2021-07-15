# ---- Create VCN Ingress Route Table on Hub VCN
resource "oci_core_route_table" "vcn_ingress_route_table" {
  compartment_id = var.network_compartment
  vcn_id         = var.firewall_vcn
  display_name   = "VCN-INGRESS"

  route_rules {
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.cluster_indoor_ip.id
  }

  route_rules {
    destination       = "10.0.0.0/20"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.cluster_indoor_ip.id
  }

  route_rules {
    destination       = "10.0.16.0/20"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_private_ip.cluster_indoor_ip.id
  }

}

# ------ Attach DRG to Hub VCN
resource "oci_core_drg_attachment" "hub_drg_attachment" {
  drg_id             = var.drg_ocid
  # vcn_id             = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  display_name       = "Firewall_VCN"
  drg_route_table_id = oci_core_drg_route_table.from_firewall_route_table.id

  network_details {
    id   = var.firewall_vcn
    type = "VCN"
    route_table_id = oci_core_route_table.vcn_ingress_route_table.id
  }
}

# ------ Attach DRG to Web Spoke VCN
resource "oci_core_drg_attachment" "web_drg_attachment" {
  drg_id             = var.drg_ocid
  vcn_id             = var.db_vcn
  display_name       = "Web_VCN"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to DB Spoke VCN
resource "oci_core_drg_attachment" "db_drg_attachment" {
  drg_id             = var.drg_ocid
  vcn_id             = var.web_vcn
  display_name       = "DB_VCN"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Create From Firewall Route Table to DRG
resource "oci_core_drg_route_table" "from_firewall_route_table" {
  drg_id                           = var.drg_ocid
  display_name                     = "From-Firewall"
  import_drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
}

# ------ Create To Firewall Route Table to DRG
resource "oci_core_drg_route_table" "to_firewall_route_table" {
  drg_id       = var.drg_ocid
  display_name = "To-Firewall"
}

# ---- Update To Firewall Route Table Pointing to Hub VCN 
resource "oci_core_drg_route_table_route_rule" "to_firewall_drg_route_table_route_rule" {
  drg_route_table_id         = oci_core_drg_route_table.to_firewall_route_table.id
  destination                = "0.0.0.0/0"
  destination_type           = "CIDR_BLOCK"
  next_hop_drg_attachment_id = oci_core_drg_attachment.hub_drg_attachment.id
}

# ---- DRG Route Import Route Distribution
resource "oci_core_drg_route_distribution" "firewall_drg_route_distribution" {
  distribution_type = "IMPORT"
  drg_id            = var.drg_ocid
  display_name      = "Transit-Spokes"
}

# ---- DRG Route Import Route Distribution Statements - One
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_one" {
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.web_drg_attachment.id
  }
  priority = "1"
}

# ---- DRG Route Import Route Distribution Statements - Two 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_two" {
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.db_drg_attachment.id
  }
  priority = "2"
}


