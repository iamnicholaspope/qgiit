# Spring Boot on Kubernetes (Oracle Cloud free tier)

This is a Spring Boot 4 / Java 21 API running on k3s (lightweight Kubernetes) on one Oracle Ampere A1 server (Arm, 2 CPU / 12 GB). Everything is defined in code: Terraform builds the server, Flux deploys the app, GitHub Actions builds and tests it.

```
GitHub push ──▶ GitHub Actions: test ─▶ build arm64 image ─▶ ghcr.io ─▶ commit new tag to k8s/
                                                                            │
Oracle A1 server (k3s) ◀── Flux pulls k8s/ every minute ◀───────────────────┘
   ├─ app (Spring Boot)            ◀── Cloudflare Tunnel ◀── https://dev.ddwellers.com
   ├─ postgres (StatefulSet)
   ├─ cloudflared (tunnel connector, 2 replicas)
   └─ nightly pg_dump ─▶ Oracle Object Storage (14-day retention)
```

| Piece | Service | Cost |
|---|---|---|
| Server + Kubernetes | Oracle A1 (2 OCPU / 12 GB) + k3s | $0 |
| PostgreSQL | Postgres 17 in the cluster | $0 |
| Backups | Oracle Object Storage (20 GB free) | $0 |
| DNS, SSL, ingress | Cloudflare free plan + Tunnel (no load balancer) | $0 |
| CI/CD | GitHub Actions + GitHub Container Registry (public repo) | $0 |
| GitOps | Flux | $0 |

## Folder layout

```
app/                 Spring Boot app + Dockerfile
infra/terraform/     Oracle network, server, backup bucket; Cloudflare tunnel + DNS
k8s/                 Everything that runs in the cluster (Flux applies this folder)
.github/workflows/   CI/CD pipeline
```

## One-time setup

### 1. Accounts

- **Oracle Cloud:** sign up, then **upgrade to Pay As You Go**. It costs $0 at this size, and it protects the server from idle reclamation. Right away, set a **budget alert** (e.g. $5) under Billing → Budgets.
- **Domain:** the app runs at `dev.ddwellers.com`. ddwellers.com's DNS is already on Cloudflare, so nothing moves. Terraform adds a single proxied `dev` record pointing at the tunnel. The root domain, `www`, and the email records keep pointing at Hostinger.
  - Before `terraform apply`, make sure no `dev` record already exists in Cloudflare. If one does, delete it or pick another name.
  - `terraform destroy` removes only the `dev` record.
- **GitHub:** create a **public** repo and push this folder to it.

### 2. Credentials

- **Oracle API key:** Profile → My profile → API keys → Add API key. Download the private key, and copy the tenancy OCID, user OCID and fingerprint.
- **Cloudflare API token:** My Profile → API Tokens → Create. Give it these permissions:
  - Zone → DNS → Edit (for ddwellers.com)
  - Account → Cloudflare Tunnel → Edit

### 3. Point the image name at your repo

In `k8s/kustomization.yaml`, replace `ghcr.io/OWNER/REPO` with your lowercase repo path, e.g. `ghcr.io/big-c/spring-k8s-oracle`. After the first run, the pipeline keeps it updated.

### 4. Build the infrastructure

```bash
cd infra/terraform
cp terraform.tfvars.example terraform.tfvars   # fill it in
terraform init
terraform plan
terraform apply
```

First boot takes about 5 minutes. To watch it, set `admin_cidr` to allow SSH, then run `ssh ubuntu@<ip> 'tail -f /var/log/cloud-init-output.log'`.

> **"Out of host capacity"?** Free Arm capacity is limited. Change the availability domain index in `compute.tf` (0/1/2) or retry later. Pay As You Go accounts usually get capacity more easily.

### 5. First deploy

Push any change under `app/`, or re-run the workflow. When it finishes:

- **Make the image public (one time).** GitHub → your profile → Packages → the image → Package settings → Change visibility → Public. The cluster then pulls it without credentials.
- **Check the app.** `https://dev.ddwellers.com/api/hello` should respond, and `.../actuator/health` should show `UP`.

## Day-to-day

```
edit code → open PR (tests run) → merge to main → live within ~3–5 min
```

- **Roll back:** revert the "deploy: …" commit in GitHub. Flux rolls the cluster back.
- **Change Kubernetes settings:** edit files in `k8s/` and push. Flux applies them; no pipeline run is needed.
- **Check status (SSH):**

  ```bash
  kubectl -n app get pods
  kubectl -n flux-system get kustomizations
  ```

## Keeping it fast and reliable

1. **Same region.** The app and the database run on the same machine.
2. **No database cold starts.** Postgres runs in the cluster and never sleeps.
3. **Uptime check.** In UptimeRobot (free) or Grafana Cloud Synthetic Monitoring (free tier), add an HTTPS check on `https://dev.ddwellers.com/actuator/health` every 5 minutes, with email alerts. It tells you when the app goes down.
   *Note:* a ping does not stop Oracle's idle reclamation, because the server still uses well under 20% CPU. **Upgrading to Pay As You Go** is what stops that.

## Monitoring (optional, free)

The app exposes Prometheus metrics at `/actuator/prometheus`. To see dashboards, create a free Grafana Cloud stack and install **Grafana Alloy** in the cluster (Grafana Cloud → Connections → Kubernetes shows the exact Helm command). Free tier: 10k metric series and 50 GB of logs per month.

## Restore a backup

```bash
# Download app-YYYYMMDD-HHMM.dump from the pg-backups bucket in the OCI console, then:
kubectl -n app cp app-....dump postgres-0:/tmp/restore.dump
kubectl -n app exec postgres-0 -- sh -c 'pg_restore -U app -d app --clean --if-exists /tmp/restore.dump'
```

## Security notes

- **No inbound ports** are open except optional SSH from your IP. Web traffic arrives through Cloudflare Tunnel.
- **GitHub never gets cluster credentials.** Flux pulls from GitHub, not the other way around.
- **Secrets** (DB password, tunnel token, backup key) are generated by Terraform and passed to the server at first boot, never committed to Git. They are also stored in Terraform state, so keep state private: use HCP Terraform (free) or keep the file off GitHub. A later upgrade is SOPS or Sealed Secrets.
