## Copyright © 2020, Oracle and/or its affiliates. 
## All rights reserved. The Universal Permissive License (UPL), Version 1.0 as shown at http://oss.oracle.com/licenses/upl

# ------ Create Dynamic Group to Support Palo Alto Networks HA
resource "oci_identity_dynamic_group" "pan_dynamic_group" {
  provider       = oci.home_region
  compartment_id = var.tenancy_ocid
  name           = var.dynamic_group_name
  description    = var.dynamic_group_description
  matching_rule  = "Any {instance.id = '${oci_core_instance.ha-vms[0].id}', instance.id = '${oci_core_instance.ha-vms[1].id}'}" 
}

# ------ Create Dynamic Group Policies to Support Palo Alto Networks HA (fix this)
resource "oci_identity_policy" "pan_firewall_ha_policy" {
  provider       = oci.home_region
  compartment_id = var.network_compartment_ocid
  description    = var.dynamic_group_policy_description
  name           = var.dynamic_group_policy_name

  statements = [
    "Allow dynamic-group ${oci_identity_dynamic_group.pan_dynamic_group.name} to use virtual-network-family in compartment ${data.oci_identity_compartment.network_compartment.name}",
    "Allow dynamic-group ${oci_identity_dynamic_group.pan_dynamic_group.name} use instance-family in compartment ${data.oci_identity_compartment.network_compartment.name}",
  ]
}
