# Database backups go to Object Storage (Always Free includes 20 GB).

data "oci_objectstorage_namespace" "ns" {
  compartment_id = var.tenancy_ocid
}

resource "oci_objectstorage_bucket" "backups" {
  compartment_id = local.compartment_id
  namespace      = data.oci_objectstorage_namespace.ns.namespace
  name           = "pg-backups"
  access_type    = "NoPublicAccess"
  versioning     = "Disabled"
}

# Object Storage needs permission to delete old objects for the lifecycle rule
resource "oci_identity_policy" "lifecycle" {
  compartment_id = var.tenancy_ocid
  name           = "objectstorage-lifecycle"
  description    = "Allow Object Storage lifecycle rules to delete old backups"
  statements = [
    "Allow service objectstorage-${var.region} to manage object-family in compartment id ${local.compartment_id}",
  ]
}

resource "oci_objectstorage_object_lifecycle_policy" "backups" {
  namespace = data.oci_objectstorage_namespace.ns.namespace
  bucket    = oci_objectstorage_bucket.backups.name

  rules {
    name        = "delete-old-backups"
    action      = "DELETE"
    is_enabled  = true
    target      = "objects"
    time_amount = var.backup_retention_days
    time_unit   = "DAYS"
  }

  depends_on = [oci_identity_policy.lifecycle]
}

# S3-compatible key the in-cluster backup job uses to upload dumps
resource "oci_identity_customer_secret_key" "backups" {
  display_name = "k3s-pg-backups"
  user_id      = var.user_ocid
}
