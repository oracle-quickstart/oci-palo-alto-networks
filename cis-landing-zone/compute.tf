# ------ Create Firewall Instances
resource "oci_core_instance" "firewall-vms" {
  depends_on = [oci_core_app_catalog_subscription.mp_image_subscription]
  count      = 2

  availability_domain = ( var.availability_domain_name != "" ? var.availability_domain_name : ( length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.network_compartment
  display_name        = "${var.vm_display_name}-${count.index + 1}"
  shape               = var.vm_compute_shape

  dynamic "shape_config" {
    for_each = local.is_flex_shape
    content {
      ocpus = shape_config.value
    }
  }

  create_vnic_details {
    subnet_id              = data.oci_core_subnets.dmz_vcn_subnets_mgmt.subnets.0.id
    display_name           = var.vm_display_name
    assign_public_ip       = true
    skip_source_dest_check = "true"
  }

  source_details {
    source_type = "image"
    source_id   = local.listing_resource_id
  }

  launch_options {
    network_type = var.instance_launch_options_network_type
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
  }
}

# ------ Attach Outdoor VNICs Attachments 
resource "oci_core_vnic_attachment" "outdoor_vnic_attachment" {
  count = 2
  create_vnic_details {
    subnet_id              = data.oci_core_subnets.dmz_vcn_subnets_outdoor.subnets.0.id
    assign_public_ip       = "false"
    skip_source_dest_check = "true"
    display_name           = "outdoor"
  }
  instance_id = oci_core_instance.firewall-vms[count.index].id
  depends_on = [
    oci_core_instance.firewall-vms,
  ]
}

# ------ Attach Indoor VNICs Attachments 
resource "oci_core_vnic_attachment" "indoor_vnic_attachment" {
  count = 2
  create_vnic_details {
    subnet_id              = data.oci_core_subnets.dmz_vcn_subnets_indoor.subnets.0.id
    assign_public_ip       = "false"
    skip_source_dest_check = "true"
    display_name           = "indoor"
  }
  instance_id = oci_core_instance.firewall-vms[count.index].id
  depends_on = [
    oci_core_vnic_attachment.outdoor_vnic_attachment
  ]
}

# ------ Attach HA VNICs Attachments 
resource "oci_core_vnic_attachment" "ha_vnic_attachment" {
  count = 2
  create_vnic_details {
    subnet_id              = data.oci_core_subnets.dmz_vcn_subnets_ha.subnets.0.id
    assign_public_ip       = "false"
    skip_source_dest_check = "true"
    display_name           = "ha"
  }
  instance_id = oci_core_instance.firewall-vms[count.index].id
  depends_on = [
    oci_core_vnic_attachment.indoor_vnic_attachment
  ]
}

# ------ Add Additional IP to Indoor Interface of Primary Firewall
resource "oci_core_private_ip" "cluster_indoor_ip" {
  vnic_id      = data.oci_core_vnic_attachments.indoor_attachments.vnic_attachments.0.vnic_id
  display_name = "firewall_indoor_secondary_private"
}

# ------ Add Additional IP to Outdoor Interface of Primary Firewall
resource "oci_core_private_ip" "cluster_outdoor_ip" {
  vnic_id      = data.oci_core_vnic_attachments.outdoor_attachments.vnic_attachments.0.vnic_id
  display_name = "firewall_outdoor_secondary_private"
}

# ------ Assign Public IP to Outdoor Interface Secondary Private IP of Primary Firewall
resource "oci_core_public_ip" "cluster_outdoor_public_ip" {
  compartment_id = var.network_compartment
  lifetime      = "RESERVED"
  private_ip_id = oci_core_private_ip.cluster_outdoor_ip.id
}