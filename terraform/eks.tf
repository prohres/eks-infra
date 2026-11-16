data "aws_iam_roles" "admin_sso" {
  name_regex  = var.admin_sso_role_regex
  path_prefix = "/aws-reserved/sso.amazonaws.com/"

  lifecycle {
    postcondition {
      condition     = length(self.names) == 1
      error_message = "Expected exactly one SSO role matching admin_sso_role_regex in account_id, found ${length(self.names)}."
    }
  }
}

module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 21.29"

  name               = var.name
  kubernetes_version = var.kubernetes_version

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  endpoint_public_access       = true
  endpoint_public_access_cidrs = var.admin_cidrs

  # Access entries only (no aws-auth ConfigMap); nobody gets admin just for running terraform
  authentication_mode                      = "API"
  enable_cluster_creator_admin_permissions = false
  access_entries = {
    admin = {
      # Full SSO role ARN with its path (/aws-reserved/sso.amazonaws.com/); only aws-auth needs the path stripped
      principal_arn = one(data.aws_iam_roles.admin_sso.arns)
      policy_associations = {
        cluster_admin = {
          policy_arn   = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSClusterAdminPolicy"
          access_scope = { type = "cluster" }
        }
      }
    }
  }

  # Secrets are envelope-encrypted with an AWS-owned key by default; a customer KMS key is a production choice
  create_kms_key    = false
  encryption_config = null

  enabled_log_types                      = ["audit", "authenticator"]
  cloudwatch_log_group_retention_in_days = 7

  addons = {
    vpc-cni                = { before_compute = true }
    eks-pod-identity-agent = { before_compute = true }
    kube-proxy             = {}
    coredns                = {}
  }

  eks_managed_node_groups = {
    default = {
      ami_type       = "AL2023_x86_64_STANDARD"
      instance_types = ["t3.medium"]
      min_size       = 1
      max_size       = 3
      desired_size   = 2
      # Module default IMDS hop limit 1: pods can't reach the node role credentials
    }
  }
}
