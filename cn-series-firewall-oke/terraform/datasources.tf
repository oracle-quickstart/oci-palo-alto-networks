data "oci_containerengine_cluster_option" "OKE_cluster_option" {
  cluster_option_id = "all"
}

data "oci_containerengine_node_pool_option" "OKE_node_pool_option" {
  node_pool_option_id = "all"
}
