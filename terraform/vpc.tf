data "aws_availability_zones" "available" {
  state = "available"
}

locals {
  azs = slice(data.aws_availability_zones.available.names, 0, 2)
}

module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 6.7"

  name = var.name
  cidr = "10.0.0.0/16"
  azs  = local.azs

  # Nodes and pods live in private subnets (VPC CNI gives pods IPs from here, so keep them large)
  private_subnets = ["10.0.0.0/19", "10.0.32.0/19"]
  public_subnets  = ["10.0.64.0/24", "10.0.65.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true # one NAT saves ~$0.05/h; for AZ-level HA use one per AZ

  # LB Controller discovers subnets by these tags: internet-facing → public, internal → private
  public_subnet_tags  = { "kubernetes.io/role/elb" = "1" }
  private_subnet_tags = { "kubernetes.io/role/internal-elb" = "1" }
}
