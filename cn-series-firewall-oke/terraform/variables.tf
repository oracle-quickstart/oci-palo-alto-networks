# ---------------------------------------------------------------------------------------------------------------------
# Environmental variables
# You probably want to define these as environmental variables.
# Instructions on that are here: https://github.com/cloud-partners/oci-prerequisites
# ---------------------------------------------------------------------------------------------------------------------

variable "compartment_ocid" {}

# Required by the OCI Provider
variable "tenancy_ocid" {}

variable "user_ocid" {}
variable "fingerprint" {}
variable "private_key_path" {}
variable "region" {}

# Key used to SSH to OCI VMs
variable "ssh_public_key" {}

# variable "ssh_private_key" {}

# ---------------------------------------------------------------------------------------------------------------------
# Optional variables
# The defaults here will give you a cluster.  You can also modify these.
# ---------------------------------------------------------------------------------------------------------------------

variable "oke" {
  type = "map"

  default = {
    name             = "OKE"
    shape            = "VM.Standard2.2"
    nodes_per_subnet = 1
  }
}
