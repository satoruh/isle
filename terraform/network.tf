resource "oci_core_vcn" "this" {
  compartment_id = oci_identity_compartment.this.id

  cidr_blocks = [local.cidr_block]
}

resource "oci_core_internet_gateway" "this" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
  enabled        = "true"
}

resource "oci_core_nat_gateway" "this" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id
}

resource "oci_core_service_gateway" "this" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  services {
    service_id = data.oci_core_services.all_oci_services.services[0].id
  }
}

resource "oci_core_route_table" "internet_gateway" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  route_rules {
    description       = "traffic to/from internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_internet_gateway.this.id
  }

  route_rules {
    description       = "traffic via vpn"
    destination       = "10.0.0.0/8"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.this.id
  }
}

resource "oci_core_route_table" "nat_gateway" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  route_rules {
    description       = "traffic to the internet"
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_nat_gateway.this.id
  }

  route_rules {
    description       = "traffic to OCI services"
    destination       = data.oci_core_services.all_oci_services.services[0].cidr_block
    destination_type  = "SERVICE_CIDR_BLOCK"
    network_entity_id = oci_core_service_gateway.this.id
  }

  route_rules {
    description       = "traffic via vpn"
    destination       = "10.0.0.0/8"
    destination_type  = "CIDR_BLOCK"
    network_entity_id = oci_core_drg.this.id
  }
}

resource "oci_core_subnet" "this" {
  for_each = local.subnets

  compartment_id             = oci_identity_compartment.this.id
  vcn_id                     = oci_core_vcn.this.id
  cidr_block                 = each.value.cidr_block
  prohibit_public_ip_on_vnic = each.value.prohibit_public_ip_on_vnic
  route_table_id             = each.value.route_table_id
  security_list_ids          = each.value.security_list_ids
}

# "lockdown" the default security list
resource "oci_core_default_security_list" "lockdown" {
  manage_default_resource_id = oci_core_vcn.this.default_security_list_id
}
