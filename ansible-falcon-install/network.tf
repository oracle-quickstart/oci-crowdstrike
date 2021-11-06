# ------ Create Web VCN
resource "oci_core_vcn" "web" {
  count          = local.use_existing_network ? 0 : 1
  cidr_block     = var.web_vcn_cidr_block
  dns_label      = var.web_vcn_dns_label
  compartment_id = var.network_compartment_ocid
  display_name   = var.web_vcn_display_name
}

# ------ Create Web VCN IGW
resource "oci_core_internet_gateway" "web_igw" {
  count          = local.use_existing_network ? 0 : 1
  compartment_id = var.network_compartment_ocid
  display_name   = "${var.web_vcn_display_name}-igw"
  vcn_id         = oci_core_vcn.web[count.index].id
  enabled        = "true"
}

# ------ Create Web Route Table and Associate to IGW
resource "oci_core_default_route_table" "web_default_route_table" {
  count                      = local.use_existing_network ? 0 : 1
  manage_default_resource_id = oci_core_vcn.web[count.index].default_route_table_id
  route_rules {
    network_entity_id = oci_core_internet_gateway.web_igw[count.index].id
    destination       = "0.0.0.0/0"
    destination_type  = "CIDR_BLOCK"
  }
}

# ------ Add Web Load Balancer Subnet to Web VCN
resource "oci_core_subnet" "web_lb-subnet" {
  count                      = local.use_existing_network ? 0 : 1
  cidr_block                 = var.web_lb_subnet_cidr_block
  compartment_id             = var.network_compartment_ocid
  vcn_id                     = oci_core_vcn.web[count.index].id
  display_name               = var.web_lb_subnet_display_name
  dns_label                  = var.web_lb_subnet_dns_label
  prohibit_public_ip_on_vnic = false
  security_list_ids          = [data.oci_core_security_lists.allow_all_security_web.security_lists[0].id]
  depends_on = [
    oci_core_security_list.allow_all_security_web,
  ]
}

# ------ Update Default Security List to All All  Rules
resource "oci_core_security_list" "allow_all_security_web" {
  compartment_id = var.network_compartment_ocid
  vcn_id         = local.use_existing_network ? var.web_vcn_id : oci_core_vcn.web.0.id
  display_name   = "AllowAll"
  ingress_security_rules {
    protocol = "all"
    source   = "0.0.0.0/0"
  }
  egress_security_rules {
    protocol    = "all"
    destination = "0.0.0.0/0"
  }
}
