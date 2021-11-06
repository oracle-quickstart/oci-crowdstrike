# ------ Get Network Compartment Name for Policies
data "oci_identity_compartment" "network_compartment" {
  id = var.network_compartment_ocid
}


# ------ Get list of availability domains
data "oci_identity_availability_domains" "ADs" {
  compartment_id = var.tenancy_ocid
}

# ------ Get the latest Oracle Linux image
data "oci_core_images" "InstanceImageOCID" {
  compartment_id = var.compute_compartment_ocid
  shape = var.spoke_vm_compute_shape

  filter {
    name   = "display_name"
    values = ["^.*Oracle[^G]*$"]
    regex  = true
  }
}

# ------ Get the Oracle Tenancy ID
data "oci_identity_tenancy" "tenancy" {
  tenancy_id = var.tenancy_ocid
}


# ------ Get the Tenancy ID and AD Number
data "oci_identity_availability_domain" "ad" {
  compartment_id = var.tenancy_ocid
  ad_number      = var.availability_domain_number
}

# ------ Get the Tenancy ID and ADs
data "oci_identity_availability_domains" "ads" {
  #Required
  compartment_id = var.tenancy_ocid
}

# ------ Get the Faulte Domain within AD 
data "oci_identity_fault_domains" "fds" {
  availability_domain = "${data.oci_identity_availability_domain.ad.name}"
  compartment_id      = var.compute_compartment_ocid

  depends_on = [
    data.oci_identity_availability_domain.ad,
  ]
}

# ------ Get the Allow All Security Lists for Subnets in Firewall VCN
data "oci_core_security_lists" "allow_all_security_web" {
  compartment_id = var.compute_compartment_ocid
  vcn_id         = local.use_existing_network ? var.web_vcn_id : oci_core_vcn.web.0.id
  filter {
    name   = "display_name"
    values = ["AllowAll"]
  }
  depends_on = [
    oci_core_security_list.allow_all_security_web,
  ]
}

# ------ Create Bastion Session
data "oci_bastion_session" "web_session" {
  session_id = oci_bastion_session.web_vm_session.id
}

# ------ Create SSH Config File
data "template_file" "ssh_userdata" {
  template = file(var.ssh_config_file)
  vars = {
    ansible_destination_ip = "${oci_core_instance.web-vms.0.public_ip}"
    private_key_path       = "${local_file.private_key_file.filename}"
    destination_ssh_user   = "${var.destination_ssh_username}"
    bastion_username       = "${data.oci_bastion_session.web_session.bastion_user_name}"
    bastion_hostname       = "host.bastion.${var.region_name}.oci.oraclecloud.com"
    destination_private_ip = "${oci_core_instance.web-vms.0.private_ip}"
  }
}

# ------ Update Falcon Server File
data "template_file" "falcon-sensor-data" {
  template = "${file(var.falcon_install)}"

  vars = {
    falcon_sensor_download_url = var.falcon_senser_rpm_download_url
    falcon_sensor_download_check_sum = var.falcon_senser_rpm_check_sum
    customer_id = var.falcon_sensor_customer_id
    falcon_sensor_rpm_name=var.falcon_sensor_rpm_name
  }
}
