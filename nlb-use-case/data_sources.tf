# ------ Get Network Compartment Name for Policies
data "oci_identity_compartment" "network_compartment" {
  id = var.network_compartment_ocid
}


# ------ Get list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# ------ Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id = var.compute_compartment_ocid
  # operating_system         = var.instance_os
  # operating_system_version = var.linux_os_version

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# ------ Get the Oracle Tenancy ID
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}


# ------ Get Your Home Region
data "oci_identity_regions" "home-region" {
  filter {
    name   = "key"
    values = [data.oci_identity_tenancy.tenancy.home_region_key]
  }
}

# ------ Get the Tenancy ID and AD Number
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

# ------ Get the Tenancy ID and ADs
data "oci_identity_availability_domains" "ads" {
  #Required
  compartment_id = var.tenancy_ocid
}

# ------ Get the Faulte Domain within AD 
data "oci_identity_fault_domains" "fds" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = var.compute_compartment_ocid

  depends_on = [
    data.oci_identity_availability_domain.ad,
  ]
}

# ------ Get the attachement based on Public Subnet
data "oci_core_vnic_attachments" "untrust_attachments" {
  compartment_id = var.network_compartment_ocid
  instance_id    = oci_core_instance.ha-vms.0.id

  filter {
    name   = "subnet_id"
    values = [local.use_existing_network ? var.untrust_subnet_id : oci_core_subnet.untrust_subnet[0].id]
  }

  depends_on = [
    oci_core_vnic_attachment.untrust_vnic_attachment,
  ]
}

# ------ Get the attachement based on Private Subnet
data "oci_core_vnic_attachments" "trust_attachments" {
  compartment_id = var.network_compartment_ocid
  instance_id    = oci_core_instance.ha-vms.0.id

  filter {
    name   = "subnet_id"
    values = [local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet[0].id]
  }

  depends_on = [
    oci_core_vnic_attachment.trust_vnic_attachment,
  ]
}

# ------ Get the Internal Private IP Address
data "oci_core_private_ip" "internal_nlb_ip" {
  private_ip_id = data.oci_core_private_ips.nlb_subnet_private_ips.id
}

# ------ Get the Internal Private IP Address
data "oci_core_private_ip" "external_nlb_ip" {
  private_ip_id = data.oci_core_private_ips.nlb_subnet_private_ips.id
}

# ------ Get the Private IPs using NLB Subnet
data "oci_core_private_ips" "nlb_subnet_private_ips" {
  subnet_id = oci_core_subnet.nlb_subnet[0].id
}

# ------ Get the Private IPs using Trust Subnet
data "oci_core_private_ips" "trust_subnet_private_ips" {
  subnet_id = oci_core_subnet.trust_subnet[0].id
  filter {
    name   = "display_name"
    values = ["Trust"]
  }
  depends_on = [
    oci_core_vnic_attachment.trust_vnic_attachment,
  ]
}

# ------ Get the Private IPs using Trust Subnet
data "oci_core_private_ips" "trust_subnet_private_nlb_ip" {
  subnet_id = oci_core_subnet.trust_subnet[0].id
  filter {
    name   = "display_name"
    values = ["PANInternalNLB"]
  }

  depends_on = [
    oci_network_load_balancer_network_load_balancer.internal_nlb,
  ]

}

# ------ Get the Private IPs using Trust Subnet
data "oci_core_private_ips" "untrust_subnet_private_nlb_ip" {
  subnet_id = oci_core_subnet.nlb_subnet[0].id
  filter {
    name   = "display_name"
    values = ["PANExternalPrivateNLB"]
  }

  depends_on = [
    oci_network_load_balancer_network_load_balancer.external_private_nlb,
  ]
}


# ------ Get the Allow All Security Lists for Subnets in Firewall VCN
data "oci_core_security_lists" "allow_all_security" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.vcn_id : oci_core_vcn.hub.0.id
  filter {
    name   = "display_name"
    values = ["AllowAll"]
  }
  depends_on = [
    oci_core_security_list.allow_all_security,
  ]
}

# ------ Get the Private IPs using Untrust Subnet
data "oci_core_private_ips" "untrust_subnet_public_ips" {
  subnet_id = oci_core_subnet.untrust_subnet[0].id

  depends_on = [
    oci_core_vnic_attachment.untrust_vnic_attachment,
  ]
}
