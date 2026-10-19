# ---------- Oracle Cloud ----------
variable "tenancy_ocid" { type = string }
variable "user_ocid" { type = string }
variable "fingerprint" { type = string }
variable "private_key_path" { type = string }

variable "region" {
  type    = string
  default = "us-ashburn-1"
}

variable "compartment_ocid" {
  description = "Compartment for all resources. Leave empty to use the tenancy root."
  type        = string
  default     = ""
}

variable "ssh_public_key" {
  description = "Your SSH public key (contents, not path)."
  type        = string
}

variable "admin_cidr" {
  description = "Your IP in CIDR form (e.g. 1.2.3.4/32) to allow SSH. Empty = no SSH port open at all."
  type        = string
  default     = ""
}

variable "ocpus" {
  description = "Always Free allows 2 OCPUs total on Ampere A1 (as of mid-2026)."
  type        = number
  default     = 2
}

variable "memory_gb" {
  description = "Always Free allows 12 GB total on Ampere A1 (as of mid-2026)."
  type        = number
  default     = 12
}

variable "boot_volume_gb" {
  description = "Always Free includes 200 GB of block storage in total."
  type        = number
  default     = 100
}

variable "backup_retention_days" {
  type    = number
  default = 14
}

# ---------- Cloudflare ----------
variable "cloudflare_api_token" {
  description = "Token with Zone:DNS:Edit and Account:Cloudflare Tunnel:Edit."
  type        = string
  sensitive   = true
}

variable "cloudflare_account_id" { type = string }
variable "cloudflare_zone_id" { type = string }

variable "hostname" {
  description = "Public hostname for the app, e.g. dev.ddwellers.com"
  type        = string
}

# ---------- GitOps ----------
variable "github_repo" {
  description = "owner/name of the GitHub repo Flux watches, e.g. BIG-C/spring-k8s-oracle"
  type        = string
}

variable "github_branch" {
  type    = string
  default = "main"
}
