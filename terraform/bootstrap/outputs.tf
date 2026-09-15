output "state_bucket_name" {
  description = "S3 bucket name used by the dev Terraform backend."
  value       = module.terraform_backend.state_bucket_name
}

output "lock_table_name" {
  description = "DynamoDB table name used to lock the dev Terraform state."
  value       = module.terraform_backend.lock_table_name
}

output "github_actions_role_arn" {
  description = "Set this value as the AWS_ROLE_TO_ASSUME GitHub repository variable."
  value       = module.github_actions_oidc.role_arn
}

output "github_actions_role_name" {
  description = "Name of the IAM role assumed by GitHub Actions through OIDC."
  value       = module.github_actions_oidc.role_name
}
