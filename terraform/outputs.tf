output "cluster" {
  value = {
    name = oci_containerengine_cluster.this.name,
    ocid = oci_containerengine_cluster.this.id,
  }
}
