# ------ Get the Availablity Domains within your Tenancy
data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

# ------ Get the Mgmt Subnet Data
data "oci_core_subnets" "dmz_vcn_subnets_mgmt" {
  compartment_id = var.network_compartment
  filter {
    name   = "display_name"
    values = ["${local.dmz_vcn_name}-${local.dmz_subnet_names[2]}-subnet"]
  }
}

# ------ Get the Outdoor Subnet Data
data "oci_core_subnets" "dmz_vcn_subnets_outdoor" {
  compartment_id = var.network_compartment
  filter {
    name   = "display_name"
    values = ["${local.dmz_vcn_name}-${local.dmz_subnet_names[0]}-subnet"]
  }
}

# ------ Get the Indoor Subnet Data
data "oci_core_subnets" "dmz_vcn_subnets_indoor" {
  compartment_id = var.network_compartment
  filter {
    name   = "display_name"
    values = ["${local.dmz_vcn_name}-${local.dmz_subnet_names[1]}-subnet"]
  }
}

# ------ Get the HA Subnet Data
data "oci_core_subnets" "dmz_vcn_subnets_ha" {
  compartment_id = var.network_compartment
  filter {
    name   = "display_name"
    values = ["${local.dmz_vcn_name}-${local.dmz_subnet_names[3]}-subnet"]
  }
}

# ------ Get the attachement based on Outdoor Subnet
data "oci_core_vnic_attachments" "outdoor_attachments" {
  compartment_id = var.network_compartment
  instance_id    = oci_core_instance.firewall-vms.0.id
  filter {
    name   = "subnet_id"
    values = [data.oci_core_subnets.dmz_vcn_subnets_outdoor.subnets.0.id]
  }
  depends_on = [
    oci_core_vnic_attachment.outdoor_vnic_attachment,
  ]
}

# ------ Get the attachement based on Indoor Subnet
data "oci_core_vnic_attachments" "indoor_attachments" {
  compartment_id = var.network_compartment
  instance_id    = oci_core_instance.firewall-vms.0.id

  filter {
    name   = "subnet_id"
    values = [data.oci_core_subnets.dmz_vcn_subnets_indoor.subnets.0.id]
  }
  depends_on = [
    oci_core_vnic_attachment.indoor_vnic_attachment,
  ]
}