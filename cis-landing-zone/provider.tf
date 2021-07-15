# ---- Terraform Version
terraform {
  required_version = ">= 0.12.0"
}

# ---- Initiate Provider
provider "oci" {
  region               = var.region
  tenancy_ocid         = var.tenancy_ocid
  user_ocid            = var.user_ocid
  fingerprint          = var.fingerprint
  private_key_path     = var.private_key_path
  private_key_password = var.private_key_password
}

# ---- Region
variable "region" {
  default = ""
}

# ---- User OCID
variable "user_ocid" {
  default = ""
}

# ---- User Fingerprint
variable "fingerprint" {
  default = ""
}

# ---- User Private Key Path
variable "private_key_path" {
  default = ""
}

# ---- User Private Key Password
variable "private_key_password" {
  default = ""
}