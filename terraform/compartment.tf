resource "oci_identity_compartment" "this" {
  compartment_id = var.parent_compartment_ocid
  description    = local.compartment.description
  name           = local.compartment.name
}
