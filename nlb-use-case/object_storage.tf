# resource "oci_objectstorage_bucket" "bootstrap" {
#   compartment_id = var.compute_compartment_ocid
#   name           = "${data.oci_identity_tenancy.tenancy.name}_bootstrap"
#   namespace      = data.oci_identity_tenancy.tenancy.name
#   # access_type    = "ObjectRead"
# }

# resource "oci_objectstorage_object" "bootstrap_config" {
#   bucket    = oci_objectstorage_bucket.bootstrap.name
#   # source    = "content/"
#   namespace = data.oci_identity_tenancy.tenancy.name
#   object    = "config/"
# }

# resource "oci_objectstorage_object" "bootstrap_license" {
#   bucket    = oci_objectstorage_bucket.bootstrap.name
#   # source    = "content/"
#   namespace = data.oci_identity_tenancy.tenancy.name
#   object    = "license/"
# }

# resource "oci_objectstorage_object" "bootstrap_software" {
#   bucket    = oci_objectstorage_bucket.bootstrap.name
#   # source    = "content/"
#   namespace = data.oci_identity_tenancy.tenancy.name
#   object    = "software/"
# }


# resource "oci_objectstorage_object" "bootstrap_content" {
#   bucket    = oci_objectstorage_bucket.bootstrap.name
#   # source    = "content/"
#   namespace = data.oci_identity_tenancy.tenancy.name
#   object    = "content/"
# }