# ------ Create Web Standalone VMs

resource "tls_private_key" "public_private_key_pair" {
  algorithm = "RSA"
}

resource "local_file" "private_key_file" {
  filename = "${path.module}/key.pem"
  content  = "${tls_private_key.public_private_key_pair.private_key_pem}"
}

resource "local_file" "ssh_config_file" {
  filename = "${path.module}/ssh-config-test"
  content  = "${data.template_file.ssh_userdata.rendered}"
}

resource "oci_bastion_bastion" "oci_bastion" {
  count                        = local.use_existing_network ? 0 : 1
  bastion_type                 = "standard"
  compartment_id               = var.compute_compartment_ocid
  target_subnet_id             = local.use_existing_network ? var.web_lb_subnet_id : oci_core_subnet.web_lb-subnet[0].id
  client_cidr_block_allow_list = [var.bastion_host_allow_cidr]
}

resource "oci_bastion_session" "web_vm_session" {
  bastion_id = oci_bastion_bastion.oci_bastion.0.id
  key_details {
    public_key_content = "${tls_private_key.public_private_key_pair.public_key_openssh}"
  }
  target_resource_details {
    session_type       = "PORT_FORWARDING"
    target_resource_id = oci_core_instance.web-vms.0.id
  }
  display_name = "web-vm"
  depends_on   = [oci_core_instance.web-vms]
}



resource "oci_core_instance" "web-vms" {
  count = 1

  availability_domain = (var.availability_domain_name != "" ? var.availability_domain_name : (length(data.oci_identity_availability_domains.ads.availability_domains) == 1 ? data.oci_identity_availability_domains.ads.availability_domains[0].name : data.oci_identity_availability_domains.ads.availability_domains[count.index].name))
  compartment_id      = var.compute_compartment_ocid
  display_name        = "${var.vm_display_name_web}-${count.index + 1}"
  shape               = var.spoke_vm_compute_shape
  fault_domain        = data.oci_identity_fault_domains.fds.fault_domains[count.index].name

  dynamic "shape_config" {
    for_each = local.is_spoke_flex_shape
    content {
      ocpus = shape_config.value
    }
  }

  create_vnic_details {
    subnet_id              = local.use_existing_network ? var.web_lb_subnet_id : oci_core_subnet.web_lb-subnet[0].id
    display_name           = var.vm_display_name_web
    assign_public_ip       = true
    skip_source_dest_check = "true"
  }

  source_details {
    source_type             = "image"
    source_id               = var.source_image_ocid
    #source_id               = data.oci_core_images.InstanceImageOCID.images[1].id
    boot_volume_size_in_gbs = "50"
  }

  launch_options {
    network_type = var.instance_launch_options_network_type
  }

  metadata = {
    ssh_authorized_keys = "${var.ssh_public_key}\n${tls_private_key.public_private_key_pair.public_key_openssh}"
  }
}

resource "local_file" "falcon_sensor" {
    content     = data.template_file.falcon-sensor-data.rendered
    filename = "${path.module}/falcon/falcon-install.yaml"
}

resource "null_resource" "install_httpd_web_vm" {
  depends_on = [oci_core_instance.web-vms, oci_bastion_session.web_vm_session, local_file.falcon_sensor]
  provisioner "remote-exec" {
    connection {
      type                = "ssh"
      user                = "opc"
      host                = oci_core_instance.web-vms.0.private_ip
      private_key         = tls_private_key.public_private_key_pair.private_key_pem
      bastion_host        = "host.bastion.${var.region_name}.oci.oraclecloud.com"
      bastion_user        = "${data.oci_bastion_session.web_session.bastion_user_name}"
      bastion_port        = 22
      bastion_private_key = tls_private_key.public_private_key_pair.private_key_pem
      timeout             = "2m"
    }
    inline = [
      "touch ~/IMadeAFile.Right.Here"
    ]
  }

  provisioner "local-exec" {
    command = "chmod 400 ${local_file.private_key_file.filename}"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook --ssh-common-args '-F ${path.module}/ssh-config-test' -i '${oci_core_instance.web-vms.0.private_ip},'  ${var.playbook_path}"
  }
}


