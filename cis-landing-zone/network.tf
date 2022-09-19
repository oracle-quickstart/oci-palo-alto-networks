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

# ------ Attach DRG to Spoke 0 VCN
resource "oci_core_drg_attachment" "vcn_0_drg_attachment" {
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_0
  display_name       = "vcn_0"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke 1 VCN
resource "oci_core_drg_attachment" "vcn_1_drg_attachment" {
  count              = length(var.vcn_1) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_1
  display_name       = "vcn_1"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke 2 VCN
resource "oci_core_drg_attachment" "vcn_2_drg_attachment" {
  count              = length(var.vcn_1) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_2
  display_name       = "vcn_2"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke 3 VCN
resource "oci_core_drg_attachment" "vcn_3_drg_attachment" {
  count              = length(var.vcn_3) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_3
  display_name       = "vcn_3"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke 4 VCN
resource "oci_core_drg_attachment" "vcn_4_drg_attachment" {
  count              = length(var.vcn_4) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_4
  display_name       = "vcn_4"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke 5 VCN
resource "oci_core_drg_attachment" "vcn_5_drg_attachment" {
  count              = length(var.vcn_5) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_5
  display_name       = "vcn_5"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke VCN
resource "oci_core_drg_attachment" "vcn_6_drg_attachment" {
  count              = length(var.vcn_6) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_6
  display_name       = "vcn_6"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke VCN
resource "oci_core_drg_attachment" "vcn_7_drg_attachment" {
  count              = length(var.vcn_7) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_7
  display_name       = "vcn_7"
  drg_route_table_id = oci_core_drg_route_table.to_firewall_route_table.id
}

# ------ Attach DRG to Spoke VCN
resource "oci_core_drg_attachment" "vcn_8_drg_attachment" {
  count              = length(var.vcn_8) > 0 ? 1 : 0
  drg_id             = var.drg_ocid
  vcn_id             = var.vcn_8
  display_name       = "vcn_8"
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
    drg_attachment_id = oci_core_drg_attachment.vcn_0_drg_attachment.id
  }
  priority = "1"
}

# ---- DRG Route Import Route Distribution Statements - Two 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_two" {
  count                     = length(var.vcn_1) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_1_drg_attachment[0].id
  }
  priority = "2"
}

# ---- DRG Route Import Route Distribution Statements - Three 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_three" {
  count                     = length(var.vcn_2) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_2_drg_attachment[0].id
  }
  priority = "3"
}

# ---- DRG Route Import Route Distribution Statements - Four 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_four" {
  count                     = length(var.vcn_3) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_3_drg_attachment[0].id
  }
  priority = "4"
}

# ---- DRG Route Import Route Distribution Statements - Five 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_five" {
  count                     = length(var.vcn_4) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_4_drg_attachment[0].id
  }
  priority = "5"
}

# ---- DRG Route Import Route Distribution Statements - Six 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_six" {
  count                     = length(var.vcn_5) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_5_drg_attachment[0].id
  }
  priority = "6"
}


# ---- DRG Route Import Route Distribution Statements - Seven 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_seven" {
  count                     = length(var.vcn_6) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_6_drg_attachment[0].id
  }
  priority = "7"
}

# ---- DRG Route Import Route Distribution Statements - Eight 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_eight" {
  count                     = length(var.vcn_7) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_7_drg_attachment[0].id
  }
  priority = "8"
}

# ---- DRG Route Import Route Distribution Statements - Ninth 
resource "oci_core_drg_route_distribution_statement" "firewall_drg_route_distribution_statement_nine" {
  count                     = length(var.vcn_8) > 0 ? 1 : 0
  drg_route_distribution_id = oci_core_drg_route_distribution.firewall_drg_route_distribution.id
  action                    = "ACCEPT"
  match_criteria {
    match_type = "DRG_ATTACHMENT_ID"
    drg_attachment_id = oci_core_drg_attachment.vcn_8_drg_attachment[0].id
  }
  priority = "9"
}