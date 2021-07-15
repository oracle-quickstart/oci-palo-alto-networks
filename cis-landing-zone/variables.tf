# ---- Tenancy OCID
variable "tenancy_ocid" {}

# ---- Marketplace Enabled Default Value
variable "mp_subscription_enabled" {
  description = "Subscribe to Marketplace listing?"
  type        = bool
  default     = true
}

# ---- Marketplace Listing OCID
variable "mp_listing_id" {
  default     = "ocid1.appcataloglisting.oc1..aaaaaaaai7wszf2tvojm2zw5epmx6ynaivbbe6zpye2kts344zg6u2jujbta"
  description = "Marketplace Listing OCID"
}

# ---- Marketplace Listing Image OCID
variable "mp_listing_resource_id" {
  default     = "ocid1.image.oc1..aaaaaaaa6enkdji2lard54gp5uycngvtkcblk22zaawh7obaibe7bmcxcalq"
  description = "Marketplace Listing Image OCID"
}

# ---- Marketplace Listing Version Name
variable "mp_listing_resource_version" {
  default     = "10.0.3"
  description = "Marketplace Listing Package/Resource Version"
}

# ---- Marketplace Template Name
variable "template_name" {
  description = "Template name. Should be defined according to deployment type"
  default     = "ha"
}

# ---- Marketplace Template Version Value
variable "template_version" {
  description = "Template version"
  default     = "20210714"
}

# ---- Network Compartment OCID 
variable "network_compartment" {
  default = ""
}

# ---- DRG OCID 
variable "drg_ocid" {
  default = ""
}

# ---- Hub/Firewal VCN OCID
variable "firewall_vcn" {
  default = ""
}

# ---- Web VCN OCID
variable "web_vcn" {
  default = ""
}

# ---- DB VCN OCID
variable "db_vcn" {
  default = ""
}

# ---- Firewall Compute Shape Value
variable "vm_compute_shape" {
  description = "Compute Shape"
  default     = "VM.Standard2.4"
}

# ---- Firewall VMs Display Name
variable "vm_display_name" {
  description = "Instance Name"
  default     = "VM-Series-Firewall"
}

# ---- Firewall VMs Flexible CPUs
variable "vm_flex_shape_ocpus" {
  description = "Flex Shape OCPUs"
  default     = 4
}

# ---- User SSH Public Key
variable "ssh_public_key" {
  description = "SSH Public Key String"
  default = ""
}

# ---- Firewall VMs Instane Launch Options
variable "instance_launch_options_network_type" {
  description = "NIC Attachment Type"
  default     = "PARAVIRTUALIZED"
}

# ---- Availabliity Domain Name
variable "availability_domain_name" {
  default     = ""
  description = "Availability Domain"
}

# ---- Firewall VMs VCN Names
variable "vcn_names" {
  type        = list(string)
  default     = ["web", "db"]
  description = "List of custom names to be given to the VCNs, overriding the default VCN names (<service-label>-<index>-vcn). The list length and elements order must match vcn_cidrs'."
  validation {
    condition     = length(var.vcn_names) < 10
    error_message = "Validation failed for vcn_names: maximum of nine allowed."
  }
}

# ---- Create Service Label 
variable "service_label" {
  validation {
    condition     = length(regexall("^[A-Za-z][A-Za-z0-9]{1,7}$", var.service_label)) > 0
    error_message = "Validation failed for service_label: value is required and must contain alphanumeric characters only, starting with a letter up to a maximum of 8 characters."
  }
}

# ---- Spoke VCN CIDR List Created using CIS Code
variable "vcn_cidrs" {
  type        = list(string)
  default     = ["10.0.0.0/20", "10.0.16.0/20"]
  description = "List of CIDR blocks for the VCNs to be created in CIDR notation. If hub_spoke_architecture is true, these VCNs are turned into spoke VCNs. You can create up to nine VCNs."
  validation {
    condition     = length(var.vcn_cidrs) < 10 && length(var.vcn_cidrs) > 0 && length([for c in var.vcn_cidrs : c if length(regexall("^(([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])\\.){3}([0-9]|[1-9][0-9]|1[0-9]{2}|2[0-4][0-9]|25[0-5])(\\/([0-9]|[1-2][0-9]|3[0-2]))?$", c)) > 0]) == length(var.vcn_cidrs)
    error_message = "Validation failed for vcn_cidrs: values must be in CIDR notation. Minimum of one required and maximum of nine allowed."
  }
}

######################
#    Enum Values     #
######################

variable "network_strategy" {
  default = "Use Existing VCN and Subnet"
}


variable "network_strategy_enum" {
  type = map
  default = {
    CREATE_NEW_VCN_SUBNET="Create New VCN and Subnet"
    USE_EXISTING_VCN_SUBNET="Use Existing VCN and Subnet"
  }
}