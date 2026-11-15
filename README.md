# eks-lab

Amazon EKS described in Terraform: VPC, EKS with a managed node group, access entries,
Pod Identity and the AWS Load Balancer Controller. A lab, built the way a production cluster would be.

## Layout

| Path | What |
|---|---|
| `terraform/` | VPC + EKS stack (state in S3, key `eks-lab/terraform.tfstate`) |

## Run locally

Account ids and the state bucket stay out of git: copy the `*.example` files and fill them in.

```bash
cd terraform
cp backend.local.hcl.example backend.local.hcl
cp accounts.auto.tfvars.example accounts.auto.tfvars
export AWS_PROFILE=sketch-root   # the provider assumes assume_role_name in the workload account
terraform init -backend-config=backend.hcl -backend-config=backend.local.hcl
terraform plan
```

## Cost

A running cluster costs about $0.25/h (control plane, 2 small nodes, NAT gateway).
Apply only for a session and destroy at the end of it.
