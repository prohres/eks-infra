variable "account_id" {
  description = "Workload account the cluster lives in (accounts.auto.tfvars, not in git)"
  type        = string
}

variable "assume_role_name" {
  description = "Role to assume in account_id when running locally; null when credentials already point there"
  type        = string
  default     = null
}

variable "region" {
  type    = string
  default = "eu-central-1"
}

variable "name" {
  type    = string
  default = "eks-infra"
}

variable "kubernetes_version" {
  description = "EKS minor version; check `aws eks describe-cluster-versions` before apply"
  type        = string
  default     = "1.35"
}

variable "admin_cidrs" {
  description = "CIDRs allowed to reach the public API endpoint, e.g. [\"<your-ip>/32\"] (accounts.auto.tfvars, not in git)"
  type        = list(string)
}

variable "admin_sso_role_regex" {
  description = "Name pattern of the SSO role that gets cluster admin (Identity Center adds a hash suffix)"
  type        = string
  default     = "^AWSReservedSSO_Admin_.*"
}
