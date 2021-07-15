# ------ Locals Variables 
locals {
  ## DMZ VCN Name, Subnet Names
  dmz_subnet_names = ["outdoor", "indoor", "mgmt", "ha", "diag"]
  dmz_vcn_name = "${var.service_label}-dmz-vcn"

  # local.use_existing_network defined in network.tf and referenced here
  use_existing_network = var.network_strategy == var.network_strategy_enum["USE_EXISTING_VCN_SUBNET"] ? true : false
  
  ### Marketplace
  mp_subscription_enabled  = var.mp_subscription_enabled ? 1 : 0
  listing_id               = var.mp_listing_id
  listing_resource_id      = var.mp_listing_resource_id
  listing_resource_version = var.mp_listing_resource_version
  is_flex_shape            = var.vm_compute_shape == "VM.Standard.E3.Flex" ? [var.vm_flex_shape_ocpus] : []
}
