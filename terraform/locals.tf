locals {
  compartment = {
    name        = "isle"
    description = "compartment for isle"
  }

  cluster_name       = "cluster01"
  kubernetes_version = "v1.30.1"

  cidr_block                                = "172.16.0.0/16"
  service_lb_subnet_cidr_block              = "172.16.20.0/24"
  node_subnet_cidr_block                    = "172.16.10.0/24"
  kubernetes_api_endpoint_subnet_cidr_block = "172.16.0.0/28"

  subnets = {
    service_lb = {
      cidr_block                 = local.service_lb_subnet_cidr_block
      prohibit_public_ip_on_vnic = "false"
      security_list_ids          = [oci_core_security_list.service_lb_sec_list.id]
      route_table_id             = oci_core_route_table.internet_gateway.id
    }
    node = {
      cidr_block                 = local.node_subnet_cidr_block
      prohibit_public_ip_on_vnic = "true"
      security_list_ids          = [oci_core_security_list.node_sec_list.id]
      route_table_id             = oci_core_route_table.nat_gateway.id
    }
    kubernetes_api_endpoint = {
      cidr_block                 = local.kubernetes_api_endpoint_subnet_cidr_block
      prohibit_public_ip_on_vnic = "false"
      security_list_ids          = [oci_core_security_list.kubernetes_api_endpoint_sec_list.id]
      route_table_id             = oci_core_route_table.internet_gateway.id
    }
  }

  images = try({
    for k, v in data.oci_containerengine_node_pool_option.this.sources : v.image_id => merge(
      try(element(regexall("OKE-(?P<k8s_version>[0-9\\.]+)-(?P<build>[0-9]+)", v.source_name), 0), { k8s_version = "none" }),
      {
        arch        = length(regexall("aarch64", v.source_name)) > 0 ? "aarch64" : "x86_64"
        image_type  = length(regexall("OKE", v.source_name)) > 0 ? "oke" : "platform"
        is_gpu      = length(regexall("GPU", v.source_name)) > 0
        os          = trimspace(replace(element(regexall("^[a-zA-Z-]+", v.source_name), 0), "-", " "))
        os_version  = element(regexall("[0-9\\.]+", v.source_name), 0)
        source_name = v.source_name
      },
    )
  }, {})

  node_pool = {
    pool01 = {
      name       = "pool01"
      node_shape = "VM.Standard.A1.Flex"
      arch       = "aarch64"
      operating_system = {
        name    = "Oracle Linux"
        version = "8.9"
      }
      is_gpu         = false
      ssh_public_key = var.ssh_public_key
      size           = "3"
      node_shape_config = {
        memory_in_gbs = "6"
        ocpus         = "1"
      }
    }
  }
}
