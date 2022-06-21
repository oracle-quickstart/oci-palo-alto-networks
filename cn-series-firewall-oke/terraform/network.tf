data "oci_identity_availability_domains" "availability_domains" {
  compartment_id = "${var.compartment_ocid}"
}

resource "oci_core_virtual_network" "virtual_network" {
  display_name   = "vcn"
  cidr_block     = "10.0.0.0/16"
  compartment_id = "${var.compartment_ocid}"
  dns_label      = "oke"
}

resource "oci_core_internet_gateway" "internet_gateway" {
  display_name   = "internet_gateway"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.virtual_network.id}"
}

resource "oci_core_route_table" "route_table" {
  display_name   = "route_table"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.virtual_network.id}"

  route_rules {
    destination       = "0.0.0.0/0"
    network_entity_id = "${oci_core_internet_gateway.internet_gateway.id}"
  }
}

resource "oci_core_security_list" "security_list" {
  display_name   = "security_list"
  compartment_id = "${var.compartment_ocid}"
  vcn_id         = "${oci_core_virtual_network.virtual_network.id}"

  egress_security_rules {
    protocol    = "All"
    destination = "0.0.0.0/0"
  }

  ingress_security_rules {
    protocol = "All"
    source   = "0.0.0.0/0"
  }
}


resource "oci_core_subnet" "subnet0" {
  display_name        = "subnet0"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"
  cidr_block          = "10.0.0.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "subnet0"
}

resource "oci_core_subnet" "subnet1" {
  display_name        = "subnet1"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[1], "name")}"
  cidr_block          = "10.0.1.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "subnet1"
}

resource "oci_core_subnet" "subnet2" {
  display_name        = "subnet2"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[2], "name")}"
  cidr_block          = "10.0.2.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "subnet2"
}

resource "oci_core_subnet" "lbsubnet0" {
  display_name        = "lbsubnet0"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[0], "name")}"
  cidr_block          = "10.0.3.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "lbsubnet0"
}

resource "oci_core_subnet" "lbsubnet1" {
  display_name        = "lbsubnet1"
  compartment_id      = "${var.compartment_ocid}"
  availability_domain = "${lookup(data.oci_identity_availability_domains.availability_domains.availability_domains[1], "name")}"
  cidr_block          = "10.0.4.0/24"
  vcn_id              = "${oci_core_virtual_network.virtual_network.id}"
  route_table_id      = "${oci_core_route_table.route_table.id}"
  security_list_ids   = ["${oci_core_security_list.security_list.id}"]
  dhcp_options_id     = "${oci_core_virtual_network.virtual_network.default_dhcp_options_id}"
  dns_label           = "lbsubnet1"
}
