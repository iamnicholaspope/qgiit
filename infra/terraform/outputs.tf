output "app_url" {
  value = "https://${var.hostname}"
}

output "server_public_ip" {
  description = "Only useful for SSH (if admin_cidr is set)."
  value       = oci_core_instance.k3s.public_ip
}

output "ssh_command" {
  value = var.admin_cidr == "" ? "SSH disabled (admin_cidr is empty)" : "ssh ubuntu@${oci_core_instance.k3s.public_ip}"
}

output "backup_bucket" {
  value = oci_objectstorage_bucket.backups.name
}
