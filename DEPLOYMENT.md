# IS311 Final Lab – Deployment Guide

This guide replaces the manual AWS Console steps in Phase 2 of the lab with
Terraform. All infrastructure is defined in the `terraform/` directory and
pulls the application code directly from this repository.

---

## Prerequisites

| Tool | Install |
|------|---------|
| [Terraform](https://developer.hashicorp.com/terraform/install) ≥ 1.14 | `mise install terraform` |
| [AWS CLI](https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html) v2 | Homebrew / installer |
| An AWS profile with EC2/VPC permissions | See your instructor |
| An SSH keypair | Generated below |

---

## Phase 1 – Planning (no AWS account needed)

### Task 1 – Architecture Diagram

Create a diagram showing:
- VPC (`10.0.0.0/16`) with one public subnet (`10.0.1.0/24`)
- Internet Gateway attached to the VPC
- EC2 instance (Ubuntu 24.04, `t3.micro`) in the public subnet
- Security Group allowing HTTP (80) and SSH (22) from your IP only
- MySQL running locally on the EC2 instance

Reference tools:
- [AWS Architecture Icons](https://aws.amazon.com/architecture/icons)
- [AWS Reference Architecture Diagrams](https://aws.amazon.com/architecture/reference-architecture-diagrams)

### Task 2 – Cost Estimate

Use the [AWS Pricing Calculator](https://calculator.aws/) to estimate 12-month
cost in `us-east-1` for:
- 1× `t3.micro` EC2 (On-Demand, ~730 hrs/month)
- 1× 20 GB `gp3` EBS volume
- Minimal data transfer out (~1 GB/month)

Reference: [What Is AWS Pricing Calculator?](https://docs.aws.amazon.com/pricing-calculator/latest/userguide/what-is-pricing-calculator.html)

Presentation template: [PowerPoint template](https://aws-tc-largeobjects.s3.us-west-2.amazonaws.com/CUR-TF-200-ACCAP1-1-79581/1-lab-capstone-project-1/s3/Academy_Lab_Projects_Showcase_template.pptx)

---

## Phase 2 – Deploying the Application

### Step 1 – Clone this repository

```bash
git clone https://github.com/JDeBo/is311-final-lab.git
cd is311-final-lab/terraform
```

### Step 2 – Generate an SSH keypair

```bash
ssh-keygen -t rsa -b 4096 -f ~/.ssh/is311-lab-key -N ""
```

This creates `~/.ssh/is311-lab-key` (private) and `~/.ssh/is311-lab-key.pub`
(public). The public key is uploaded to AWS as an EC2 Key Pair automatically
by Terraform.

### Step 3 – Configure your AWS profile

The Terraform config uses the `emerge-cdk` profile by default. To use a
different profile, edit `terraform/main.tf`:

```hcl
provider "aws" {
  profile = "your-profile-name"
  region  = "us-east-1"
}
```

Verify your credentials work:

```bash
aws sts get-caller-identity --profile your-profile-name
```

### Step 4 – Deploy

```bash
terraform init
terraform apply
```

Terraform will:
1. Look up your current public IP via `checkip.amazonaws.com`
2. Create `FinalVPC` (`10.0.0.0/16`) with DNS hostnames enabled
3. Create `FinalIGW` and attach it to the VPC
4. Create `Public Subnet 1` (`10.0.1.0/24`) in `us-east-1a`
5. Create a public route table with a default route to the IGW
6. Create `FinalAPPSG` — HTTP (80) and SSH (22) open to **your IP only**
7. Upload your SSH public key as `is311-lab-key`
8. Find the latest Ubuntu 24.04 LTS AMI (Canonical)
9. Launch `FinalPOC` (`t3.micro`, 20 GB gp3) and run the userdata script

The userdata script:
- Installs `nodejs`, `npm`, `mysql-server`, `git`
- Applies a MySQL 8.4 compatibility fix for `mysql_native_password`
- Clones this repo to `/home/ubuntu/app`
- Creates the `STUDENTS` database and `students` table
- Starts the Node.js app on port 80

Apply takes ~2 minutes. Once complete, outputs are printed:

```
app_url     = "http://<public-ip>"
public_ip   = "<public-ip>"
instance_id = "i-xxxxxxxxxxxxxxxxx"
ssh_command = "ssh -i ~/.ssh/is311-lab-key.pem ubuntu@<public-ip>"
```

### Step 5 – Wait for the app to start

The userdata script runs in the background after the instance boots. Wait
about 3–5 minutes, then open `app_url` in your browser.

To check progress via SSH:

```bash
# Use the ssh_command from terraform output
ssh -i ~/.ssh/is311-lab-key.pem ubuntu@<public-ip>
sudo tail -f /var/log/cloud-init-output.log
```

### Step 6 – Test the application

Navigate to `http://<public-ip>` in your browser. You should see the XYZ
University student records app. Test all four operations:

| Operation | How |
|-----------|-----|
| View records | Click **Students list** in the nav |
| Add a record | Click **Add a new student**, fill the form, click **Submit** |
| Edit a record | Click **edit** on any row, update fields, click **Submit** |
| Delete a record | Click **edit** on any row, click **Delete** |

---

## Re-deploying after an IP change

If your public IP changes (e.g. next day, different network), just re-run:

```bash
terraform apply
```

Terraform will detect the new IP and update the security group rules
in-place — no instance restart needed.

---

## Tearing down

```bash
terraform destroy
```

This removes all resources created by Terraform. If the state is lost or
out of sync, clean up manually:

```bash
# Terminate the instance
aws ec2 terminate-instances --region us-east-1 --instance-ids <instance-id>

# Then delete: security group, subnet, route table, IGW, VPC, key pair
# (in that order — VPC must be last)
```

---

## Application code notes

The app lives in `resources/codebase_partner/` and is a Node.js/Express CRUD
app backed by MySQL. Key files:

| File | Purpose |
|------|---------|
| `index.js` | Express server, routes |
| `app/config/config.js` | DB config — tries AWS Secrets Manager, falls back to env vars |
| `app/models/supplier.model.js` | MySQL queries |
| `app/controller/supplier.controller.js` | Route handlers + validation |

The app reads DB connection details from environment variables:

| Variable | Value set by userdata |
|----------|----------------------|
| `APP_DB_HOST` | EC2 private IP (from instance metadata) |
| `APP_DB_USER` | `nodeapp` |
| `APP_DB_PASSWORD` | `student12` |
| `APP_DB_NAME` | `STUDENTS` |
| `APP_PORT` | `80` |
