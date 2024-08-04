data "oci_core_services" "all_oci_services" {}

data "oci_identity_availability_domains" "this" {
  compartment_id = oci_identity_compartment.this.id
}

data "oci_containerengine_node_pool_option" "this" {
  compartment_id      = oci_identity_compartment.this.id
  node_pool_option_id = oci_containerengine_cluster.this.id
}
