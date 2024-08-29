resource "random_bytes" "vpn_ipsec_psk" {
  length = 24
}

resource "oci_core_drg" "this" {
  compartment_id = oci_identity_compartment.this.id
}

resource "oci_core_drg_attachment" "this" {
  drg_id = oci_core_drg.this.id

  network_details {
    id   = oci_core_vcn.this.id
    type = "VCN"
  }
}

resource "oci_core_cpe" "this" {
  compartment_id = oci_identity_compartment.this.id
  ip_address     = var.cpe_ip_address
}

resource "oci_core_ipsec" "this" {
  compartment_id = oci_identity_compartment.this.id
  cpe_id         = oci_core_cpe.this.id
  drg_id         = oci_core_drg.this.id
  static_routes  = ["10.0.0.0/8"]
}

data "oci_core_ipsec_connection_tunnels" "this" {
  ipsec_id = oci_core_ipsec.this.id
}

resource "oci_core_ipsec_connection_tunnel_management" "this" {
  for_each = toset([for e in data.oci_core_ipsec_connection_tunnels.this.ip_sec_connection_tunnels : e.id])

  ipsec_id      = oci_core_ipsec.this.id
  tunnel_id     = each.value
  routing       = "STATIC"
  shared_secret = random_bytes.vpn_ipsec_psk.base64
  ike_version   = "V2"
}
