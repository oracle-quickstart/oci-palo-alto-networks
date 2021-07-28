resource "oci_core_network_security_group" "nsg" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id

  display_name = var.nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "rule_ingress_all" {
  network_security_group_id = oci_core_network_security_group.nsg.id
  direction = "INGRESS"
  protocol  = "all"
  source    = "0.0.0.0/0"
}


resource "oci_core_network_security_group" "nsg_web" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.web.0.id
  display_name = var.web_nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "web_rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_web.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "web_rule_ingress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_web.id
  direction = "INGRESS"
  protocol  = "all"
  source    = "0.0.0.0/0"
}


resource "oci_core_network_security_group" "nsg_db" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.db.0.id
  display_name = var.db_nsg_display_name
}

resource "oci_core_network_security_group_security_rule" "db_rule_egress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_db.id
  direction                 = "EGRESS"
  protocol                  = "all"
  destination               = "0.0.0.0/0"
}

resource "oci_core_network_security_group_security_rule" "db_rule_ingress_all" {
  network_security_group_id = oci_core_network_security_group.nsg_db.id
  direction = "INGRESS"
  protocol  = "all"
  source    = "0.0.0.0/0"
}
