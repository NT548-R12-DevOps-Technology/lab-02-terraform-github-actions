
# Identifies the AWS account for the DynamoDB state-lock policy.
data "aws_caller_identity" "current" {}

locals {
  name_prefix = "${var.project_name}-${var.environment}"
  common_tags = {
    Project     = var.project_name
    Environment = var.environment
    ManagedBy   = "Terraform"
    Purpose     = "TerraformStateBackend"
  }
}

# Apply this root module once before initializing the dev environment.
module "terraform_backend" {
  source = "../modules/terraform_backend"

  state_bucket_name = var.state_bucket_name
  lock_table_name   = "${local.name_prefix}-terraform-lock"
  tags              = local.common_tags
}

# Creates the GitHub Actions OIDC provider and the role assumed by CI/CD.
module "github_actions_oidc" {
  source = "../modules/github_actions_oidc"

  aws_account_id         = data.aws_caller_identity.current.account_id
  aws_region             = var.aws_region
  github_organization    = var.github_organization
  github_organization_id = var.github_organization_id
  github_repository      = var.github_repository
  github_repository_id   = var.github_repository_id
  github_environment     = var.github_environment
  role_name              = "${local.name_prefix}-github-actions"
  state_bucket_name      = var.state_bucket_name
  lock_table_name        = module.terraform_backend.lock_table_name
  tags                   = local.common_tags
}
