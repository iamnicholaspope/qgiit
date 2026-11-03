# Project hostnames

`dev.ddwellers.com` is routed to the shared gateway. The original Spring service
still handles `/qgiit/`, `/api/` and other unregistered preview paths.

Additional project domains must be active Cloudflare zones accessible to the
configured token. Preserve existing website and mail DNS while onboarding them.
Changing nameservers happens at the registrar; adding a domain to cPanel does
not give this Terraform configuration control of its authoritative DNS.

After Cormibo is active in Cloudflare, add its development hostname to the private
`terraform.tfvars`, using the real zone ID:

```hcl
project_hostnames = {
  "dev.cormibo.com" = "<cormibo-cloudflare-zone-id>"
}
```

Review `terraform plan`. The intended change is a development CNAME plus the
tunnel hostname route. Apply only that reviewed scope; do not overwrite a
preexisting DNS record. Import an existing record into Terraform first if needed.
Then change `development_verify_url` in the private ddwellers project's
`deployment/projects/projects.json` to `https://dev.cormibo.com/`.

When production is finalized, deploy the selected verified image using the
project production workflow. Add `cormibo.com` and `www.cormibo.com` to this map
at first launch, after reconciling/importing any existing web records. Both map
to the production service through the gateway. Preserve mail records and any
mail hostnames that still point to cPanel. Confirm HTTPS and public release health.

Do not add apex/www merely to enable a development preview. The initial map is
empty and leaves Cormibo's live cPanel website in place.
