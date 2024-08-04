resource "oci_containerengine_cluster" "this" {
  compartment_id     = oci_identity_compartment.this.id
  vcn_id             = oci_core_vcn.this.id
  kubernetes_version = local.kubernetes_version
  name               = local.cluster_name
  type               = "BASIC_CLUSTER"
  freeform_tags = {
    OKEclusterName = local.cluster_name
  }

  cluster_pod_network_options {
    cni_type = "OCI_VCN_IP_NATIVE"
  }

  endpoint_config {
    is_public_ip_enabled = "true"
    subnet_id            = oci_core_subnet.this["kubernetes_api_endpoint"].id
  }

  options {
    service_lb_subnet_ids = [oci_core_subnet.this["service_lb"].id]

    admission_controller_options {
      is_pod_security_policy_enabled = "false"
    }

    persistent_volume_config {
      freeform_tags = {
        OKEclusterName = local.cluster_name
      }
    }

    service_lb_config {
      freeform_tags = {
        OKEclusterName = local.cluster_name
      }
    }
  }
}

resource "oci_containerengine_node_pool" "this" {
  for_each = local.node_pool

  compartment_id     = oci_identity_compartment.this.id
  cluster_id         = oci_containerengine_cluster.this.id
  kubernetes_version = local.kubernetes_version
  name               = each.value.name
  node_shape         = each.value.node_shape
  ssh_public_key     = each.value.ssh_public_key
  freeform_tags = {
    OKEclusterName  = local.cluster_name
    OKEnodePoolName = each.value.name
  }

  initial_node_labels {
    key   = "name"
    value = local.cluster_name
  }

  node_config_details {
    size = each.value.size
    freeform_tags = {
      OKEclusterName  = local.cluster_name
      OKEnodePoolName = each.value.name
    }

    node_pool_pod_network_option_details {
      cni_type       = "OCI_VCN_IP_NATIVE"
      pod_subnet_ids = [oci_core_subnet.this["node"].id]
    }

    dynamic "placement_configs" {
      for_each = data.oci_identity_availability_domains.this.availability_domains

      content {
        availability_domain = placement_configs.value.name
        subnet_id           = oci_core_subnet.this["node"].id

      }
    }
  }

  node_eviction_node_pool_settings {
    eviction_grace_duration = "PT1H" # default
  }

  node_shape_config {
    memory_in_gbs = each.value.node_shape_config.memory_in_gbs
    ocpus         = each.value.node_shape_config.ocpus
  }

  node_source_details {
    image_id = element([for k, v in local.images : k if
      "v${lookup(v, "k8s_version", "")}" == local.kubernetes_version &&
      lookup(v, "arch", "") == each.value.arch &&
      lookup(v, "image_type", "") == "oke" &&
      lookup(v, "is_gpu", true) == each.value.is_gpu &&
      lookup(v, "os", "") == each.value.operating_system.name &&
      lookup(v, "os_version", "") == each.value.operating_system.version],
      0)
    source_type = "IMAGE"
  }
}
