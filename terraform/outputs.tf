output "cluster" {
  value = {
    name = oci_containerengine_cluster.this.name,
    ocid = oci_containerengine_cluster.this.id,
  }
}

output "vpn_ipsec_psk" {
  value     = random_bytes.vpn_ipsec_psk.base64
  sensitive = true
}

output "vpn_ip" {
  value = [ for k, v in oci_core_ipsec_connection_tunnel_management.this : v.vpn_ip ]
}
