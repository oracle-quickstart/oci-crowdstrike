#Variables declared in this file must be declared in the marketplace.yaml

############################
#  Hidden Variable Group   #
############################
variable "tenancy_ocid" {
}

variable "region" {
}

############################
#  Compute Configuration   #
############################

variable "vm_display_name_web" {
  description = "Instance Name"
  default     = "web-app"
}

variable "spoke_vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.1" //2 cores
}

variable "source_image_ocid" {
  description = "CrowdStrike Supported Image Oracle Linux VM Source ID"
  default = "ocid1.image.oc1.iad.aaaaaaaakjvsts7rf7umrlqtw5hbhc3gjotadu7thfn5cfathwdn3awht7ca"
}

variable "create_custom_image" {
  type        = bool
  default = false
  description = "Enable creating custom image out of Web VM Instance"
}

variable "spoke_vm_flex_shape_ocpus" {
  description = "Spoke VMs Flex Shape OCPUs"
  default     = 4
}
variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain"
}

variable "availability_domain_number" {
  default     = 1
  description = "OCI Availability Domains: 1,2,3  (subject to region availability)"
}

variable "ssh_public_key" {
  description = "SSH Public Key String"
}

variable "region_name" {
  description = "Bastion Region Name"
  default = "us-ashburn-1"
}

variable "ssh_config_file" {
  description = "SSH Private Key Path"
  default     = "./ssh-config/ssh-config.tpl"
}

variable "bastion_host_allow_cidr" {
  description = "Bastion Host Allow CIDR"
  default = "0.0.0.0/0"
}


variable "destination_ssh_username" {
  description = "SSH Username"
  default     = "opc"
}

variable "playbook_path" {
  description = "Falcon ansible playbook path"
  default     = "./falcon/falcon-install.yaml"
}

variable "instance_launch_options_network_type" {
  description = "NIC Attachment Type"
  default     = "PARAVIRTUALIZED"
}

############################
#  Network Configuration   #
############################

variable "network_strategy" {
  default = "Create New VCN and Subnet"
}

variable "web_vcn_id" {
  default = ""
}

variable "web_vcn_cidr_block" {
  description = "Web Spoke VCN CIDR Block"
  default     = "10.0.0.0/24"
}

variable "web_vcn_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "web"
}

variable "web_vcn_display_name" {
  description = "Web Spoke VCN Display Name"
  default     = "web-vcn"
}

variable "web_lb_subnet_id" {
  default = ""
}

variable "web_lb_subnet_cidr_block" {
  description = "Web Spoke VCN Loadbalancer Subnet"
  default     = "10.0.0.0/25"
}

variable "web_lb_subnet_display_name" {
  description = "Web Spoke VCN LB Subnet Display Name"
  default     = "web_lb-subnet"
}

variable "web_lb_subnet_dns_label" {
  description = "Web Spoke VCN DNS Label"
  default     = "weblb"
}

###############################
# Falcon Sensor Configuration #
###############################

variable "falcon_senser_rpm_download_url" {
  default = ""
}

variable "falcon_senser_rpm_check_sum" {
  default = ""
}


variable "falcon_sensor_customer_id" {
  default = ""
}

variable "falcon_install" {
  default = "./falcon/falcon-install.tpl"
}

variable "falcon_sensor_rpm_name" {
  default = ""
}

############################
# Additional Configuration #
############################

variable "compute_compartment_ocid" {
  description = "Compartment where Compute and Marketplace subscription resources will be created"
}

variable "network_compartment_ocid" {
  description = "Compartment where Network resources will be created"
}

variable "template_name" {
  description = "Template name. Should be defined according to deployment type"
  default     = "ansible"
}

variable "template_version" {
  description = "Template version"
  default     = "20210724"
}

######################
#    Enum Values     #   
######################
variable "network_strategy_enum" {
  type = map
  default = {
    CREATE_NEW_VCN_SUBNET   = "Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET = "Use Existing VCN and Subnet"
  }
}

variable "subnet_type_enum" {
  type = map
  default = {
    transit_subnet    = "Private Subnet"
    MANAGEMENT_SUBENT = "Public Subnet"
  }
}

variable "nsg_config_enum" {
  type = map
  default = {
    BLOCK_ALL_PORTS = "Block all ports"
    OPEN_ALL_PORTS  = "Open all ports"
    CUSTOMIZE       = "Customize ports - Post deployment"
  }
}
