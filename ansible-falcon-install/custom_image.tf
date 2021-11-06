resource "oci_core_image" "instance_image" {
    depends_on = [null_resource.install_httpd_web_vm]
    count = var.create_custom_image ? 1 : 0
    compartment_id = var.compute_compartment_ocid
    instance_id = oci_core_instance.web-vms.0.id
    display_name = "custom-httpd-image"
}