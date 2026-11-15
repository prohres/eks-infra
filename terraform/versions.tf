terraform {
  required_version = ">= 1.10"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 6.59" }
  }

  backend "s3" {
    key = "eks-infra/terraform.tfstate" # shared settings: backend.hcl; bucket: backend.local.hcl
  }
}

# The whole stack lives in the workload account. Locally the profile credentials assume assume_role_name there.
provider "aws" {
  region              = var.region
  allowed_account_ids = [var.account_id]
  dynamic "assume_role" {
    for_each = var.assume_role_name == null ? [] : [var.assume_role_name]
    content {
      role_arn = "arn:aws:iam::${var.account_id}:role/${assume_role.value}"
    }
  }
  default_tags {
    tags = { project = "eks-infra", env = "dev", managed-by = "terraform", repo = "prohres/eks-infra" }
  }
}
