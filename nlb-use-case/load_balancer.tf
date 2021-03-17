
resource "oci_load_balancer_load_balancer" "WebLB" {
  count          = local.use_existing_network ? 0 : 1
  shape          = "100Mbps"
  compartment_id = var.compute_compartment_ocid
  subnet_ids = [
    "${oci_core_subnet.web_lb-subnet[count.index].id}"
  ]
  display_name = "WebLB"
  is_private   = false
}

resource "oci_load_balancer_backend_set" "lb-web-backend" {
  count            = local.use_existing_network ? 0 : 1
  name             = "lb-web-backend"
  load_balancer_id = oci_load_balancer_load_balancer.WebLB[count.index].id
  policy           = "ROUND_ROBIN"
  health_checker {
    port                = "80"
    protocol            = "HTTP"
    response_body_regex = ".*"
    url_path            = "/"
  }
}

resource "oci_load_balancer_listener" "lb-web-listener" {
  count                    = local.use_existing_network ? 0 : 1
  load_balancer_id         = oci_load_balancer_load_balancer.WebLB[count.index].id
  name                     = "http"
  default_backend_set_name = oci_load_balancer_backend_set.lb-web-backend[count.index].name
  port                     = 80
  protocol                 = "HTTP"
  connection_configuration {
    idle_timeout_in_seconds = "2"
  }
}

# ------ Add a new Backend Set to Load Balancer

resource "oci_load_balancer_backend" "lb_backends_1" {
  count            = local.use_existing_network ? 0 : 1
  backendset_name  = oci_load_balancer_backend_set.lb-web-backend[count.index].name
  ip_address       = oci_core_instance.web-vms.0.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.WebLB[count.index].id
  port             = var.backend_port
}

# ------ Add a new Backend Set to Load Balancer

resource "oci_load_balancer_backend" "lb_backends_2" {
  count            = local.use_existing_network ? 0 : 1
  backendset_name  = oci_load_balancer_backend_set.lb-web-backend[count.index].name
  ip_address       = oci_core_instance.web-vms.1.private_ip
  load_balancer_id = oci_load_balancer_load_balancer.WebLB[count.index].id
  port             = var.backend_port

}