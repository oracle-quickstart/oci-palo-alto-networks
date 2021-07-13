# ------ Network Load Balancer Palo Alto Networks Untrust Interface 
resource "oci_network_load_balancer_network_load_balancer" "external_nlb" {
  compartment_id = var.compute_compartment_ocid

  subnet_id = local.use_existing_network ? var.nlb_subnet_id : oci_core_subnet.nlb_subnet.0.id

  is_preserve_source_destination = true
  display_name                   = "PANExternalPublicNLB"
  is_private                     = false
}


resource "oci_network_load_balancer_backend_set" "external-lb-backend" {
  name                     = "external-lb-backend"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_nlb.id
  policy                   = "FIVE_TUPLE"
  health_checker {
    port        = "443"
    protocol    = "HTTPS"
    return_code = 200
    url_path    = "/php/login.php"
  }
}

resource "oci_network_load_balancer_listener" "external-lb-listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_nlb.id
  name                     = "firewall-untrust"
  default_backend_set_name = oci_network_load_balancer_backend_set.external-lb-backend.name
  port                     = "0"
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend" "external-public-lb-ends01" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.external-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.untrust_subnet_public_ips.private_ips[0].id
}

resource "oci_network_load_balancer_backend" "external-public-lb-ends02" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.external-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.untrust_subnet_public_ips.private_ips[1].id
}


# ------ Network Load Balancer Palo Alto Networks Private for On-Prem Connectivity
resource "oci_network_load_balancer_network_load_balancer" "external_private_nlb" {
  compartment_id = var.compute_compartment_ocid
  subnet_id = local.use_existing_network ? var.nlb_subnet_id : oci_core_subnet.nlb_subnet.0.id

  is_preserve_source_destination = true
  display_name                   = "PANExternalPrivateNLB"
  is_private                     = true
}


resource "oci_network_load_balancer_backend_set" "external-private-lb-backend" {
  name                     = "external-private-lb-backend"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_private_nlb.id
  policy                   = "FIVE_TUPLE"
  health_checker {
    port        = "443"
    protocol    = "HTTPS"
    return_code = 200
    url_path    = "/php/login.php"
  }
}

resource "oci_network_load_balancer_listener" "external-private-lb-listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_private_nlb.id
  name                     = "firewall-untrust"
  default_backend_set_name = oci_network_load_balancer_backend_set.external-private-lb-backend.name
  port                     = "0"
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend" "external-private-lb-ends01" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_private_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.external-private-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.untrust_subnet_public_ips.private_ips[0].id
}

resource "oci_network_load_balancer_backend" "external-private-lb-ends02" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.external_private_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.external-private-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.untrust_subnet_public_ips.private_ips[1].id
}

# ------ Network Load Balancer Palo Alto Networks Trust Interface 
resource "oci_network_load_balancer_network_load_balancer" "internal_nlb" {
  compartment_id = var.compute_compartment_ocid
  subnet_id = local.use_existing_network ? var.trust_subnet_id : oci_core_subnet.trust_subnet.0.id
  is_preserve_source_destination = true
  display_name                   = "PANInternalNLB"
  is_private                     = true
}

resource "oci_network_load_balancer_backend_set" "internal-lb-backend" {
  name                     = "internal-lb-backend"
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal_nlb.id
  policy                   = "FIVE_TUPLE"
  health_checker {
    port        = "443"
    protocol    = "HTTPS"
    return_code = 200
    url_path    = "/php/login.php"
  }
}

resource "oci_network_load_balancer_listener" "internal-lb-listener" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal_nlb.id
  name                     = "firewall-trust"
  default_backend_set_name = oci_network_load_balancer_backend_set.internal-lb-backend.name
  port                     = "0"
  protocol                 = "ANY"
}

resource "oci_network_load_balancer_backend" "internal-lb-ends01" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.internal-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.trust_subnet_private_ips.private_ips[0].id
}


resource "oci_network_load_balancer_backend" "internal-lb-ends02" {
  network_load_balancer_id = oci_network_load_balancer_network_load_balancer.internal_nlb.id
  backend_set_name         = oci_network_load_balancer_backend_set.internal-lb-backend.name
  port                     = "0"
  target_id = data.oci_core_private_ips.trust_subnet_private_ips.private_ips[1].id
}
