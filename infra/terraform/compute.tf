data "oci_identity_availability_domains" "ads" {
  compartment_id = var.tenancy_ocid
}

data "oci_core_images" "ubuntu_arm" {
  compartment_id           = local.compartment_id
  operating_system         = "Canonical Ubuntu"
  operating_system_version = "24.04"
  shape                    = "VM.Standard.A1.Flex"
  sort_by                  = "TIMECREATED"
  sort_order               = "DESC"
}

resource "random_password" "db" {
  length  = 32
  special = false
}

resource "oci_core_instance" "k3s" {
  compartment_id = local.compartment_id
  # If you get "Out of host capacity", try another availability domain index (0, 1 or 2).
  availability_domain = data.oci_identity_availability_domains.ads.availability_domains[0].name
  display_name        = "k3s-node"
  shape               = "VM.Standard.A1.Flex"

  shape_config {
    ocpus         = var.ocpus
    memory_in_gbs = var.memory_gb
  }

  source_details {
    source_type             = "image"
    source_id               = data.oci_core_images.ubuntu_arm.images[0].id
    boot_volume_size_in_gbs = var.boot_volume_gb
  }

  create_vnic_details {
    subnet_id        = oci_core_subnet.public.id
    assign_public_ip = true # needed for outbound internet; no inbound ports are open
  }

  metadata = {
    ssh_authorized_keys = var.ssh_public_key
    user_data = base64encode(templatefile("${path.module}/cloud-init.sh.tftpl", {
      db_password       = random_password.db.result
      tunnel_token      = data.cloudflare_zero_trust_tunnel_cloudflared_token.app.token
      s3_access_key     = oci_identity_customer_secret_key.backups.id
      s3_secret_key     = oci_identity_customer_secret_key.backups.key
      s3_endpoint       = "https://${data.oci_objectstorage_namespace.ns.namespace}.compat.objectstorage.${var.region}.oraclecloud.com"
      s3_region         = var.region
      s3_bucket         = oci_objectstorage_bucket.backups.name
      github_repo       = var.github_repo
      github_branch     = var.github_branch
    }))
  }

  lifecycle {
    # Don't rebuild the server every time Oracle publishes a newer Ubuntu image
    ignore_changes = [source_details[0].source_id, metadata]
  }
}
