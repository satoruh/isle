resource "oci_core_security_list" "service_lb_sec_list" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_security_list" "node_sec_list" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  egress_security_rules {
    description      = "Allow pods on one worker node to communicate with pods on other worker nodes"
    destination      = local.node_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "Access to Kubernetes API Endpoint"
    destination      = local.kubernetes_api_endpoint_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "Kubernetes worker to control plane communication"
    destination      = local.kubernetes_api_endpoint_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "Path discovery"
    destination      = local.kubernetes_api_endpoint_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "1"
    stateless        = "false"

    icmp_options {
      code = "4"
      type = "3"
    }
  }

  egress_security_rules {
    description      = "Allow nodes to communicate with OKE to ensure correct start-up and continued functioning"
    destination      = "all-kix-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "ICMP Access from Kubernetes Control Plane"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "1"
    stateless        = "false"

    icmp_options {
      code = "4"
      type = "3"
    }
  }

  egress_security_rules {
    description      = "Worker Nodes access to Internet"
    destination      = "0.0.0.0/0"
    destination_type = "CIDR_BLOCK"
    protocol         = "all"
    stateless        = "false"
  }

  ingress_security_rules {
    description = "Allow pods on one worker node to communicate with pods on other worker nodes"
    protocol    = "all"
    source      = local.node_subnet_cidr_block
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Path discovery"
    protocol    = "1"
    source      = local.kubernetes_api_endpoint_subnet_cidr_block
    stateless   = "false"

    icmp_options {
      code = "4"
      type = "3"
    }
  }

  ingress_security_rules {
    description = "TCP access from Kubernetes Control Plane"
    protocol    = "6"
    source      = local.kubernetes_api_endpoint_subnet_cidr_block
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Inbound SSH traffic to worker nodes"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "oci_core_security_list" "kubernetes_api_endpoint_sec_list" {
  compartment_id = oci_identity_compartment.this.id
  vcn_id         = oci_core_vcn.this.id

  egress_security_rules {
    description      = "Allow Kubernetes Control Plane to communicate with OKE"
    destination      = "all-kix-services-in-oracle-services-network"
    destination_type = "SERVICE_CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "All traffic to worker nodes"
    destination      = local.node_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "6"
    stateless        = "false"
  }

  egress_security_rules {
    description      = "Path discovery"
    destination      = local.node_subnet_cidr_block
    destination_type = "CIDR_BLOCK"
    protocol         = "1"
    stateless        = "false"

    icmp_options {
      code = "4"
      type = "3"
    }
  }

  ingress_security_rules {
    description = "External access to Kubernetes API endpoint"
    protocol    = "6"
    source      = "0.0.0.0/0"
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Kubernetes worker to Kubernetes API endpoint communication"
    protocol    = "6"
    source      = local.node_subnet_cidr_block
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Kubernetes worker to control plane communication"
    protocol    = "6"
    source      = local.node_subnet_cidr_block
    stateless   = "false"
  }

  ingress_security_rules {
    description = "Path discovery"
    protocol    = "1"
    source      = local.node_subnet_cidr_block
    stateless   = "false"

    icmp_options {
      code = "4"
      type = "3"
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}
