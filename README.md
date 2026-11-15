# eks-infra

Amazon EKS described in Terraform: VPC, EKS with a managed node group, access entries,
Pod Identity and the IAM side of the AWS Load Balancer Controller.

## Layout

| Path | What |
|---|---|
| `terraform/` | VPC + EKS stack (state in S3, key `eks-infra/terraform.tfstate`) |

The Load Balancer Controller itself (Helm chart) is installed by ArgoCD, not by Terraform:
Terraform builds the infrastructure, ArgoCD manages what runs inside the cluster.

## Design decisions

- Access entries only (`authentication_mode = "API"`), no aws-auth ConfigMap; the identity that runs
  Terraform gets no cluster admin, admins are listed explicitly.
- AWS permissions for pods come from Pod Identity, never from the node role; IMDS hop limit 1 keeps pods
  away from node credentials.
- Subnet tags `kubernetes.io/role/elb` (public) and `kubernetes.io/role/internal-elb` (private) let the
  Load Balancer Controller discover subnets.
- Public API endpoint, restricted to `admin_cidrs`.
- One NAT gateway to keep cost down; one per AZ for AZ-level HA.

## Run locally

Account ids, the state bucket and allowed CIDRs stay out of git: copy the `*.example` files and fill them in.

```bash
cd terraform
cp backend.local.hcl.example backend.local.hcl
cp accounts.auto.tfvars.example accounts.auto.tfvars
export AWS_PROFILE=<profile>   # the provider assumes assume_role_name in the workload account
terraform init -backend-config=backend.hcl -backend-config=backend.local.hcl
terraform plan
```

## Cost

A running cluster costs about $0.25/h (control plane, 2 nodes, NAT gateway).
Apply only when needed and destroy afterwards.
