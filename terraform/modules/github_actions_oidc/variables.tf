variable "aws_account_id" {
  description = "AWS account ID that owns the Terraform state lock table."
  type        = string
  nullable    = false
}

variable "aws_region" {
  description = "AWS Region containing the Terraform state lock table."
  type        = string
  nullable    = false
}

variable "github_organization" {
  description = "GitHub organization allowed to run the deployment workflow."
  type        = string
  nullable    = false
}

variable "github_organization_id" {
  description = "Immutable numeric ID of the GitHub organization allowed to run the deployment workflow."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+$", var.github_organization_id))
    error_message = "github_organization_id must contain only digits."
  }
}

variable "github_repository" {
  description = "GitHub repository name allowed to run the deployment workflow."
  type        = string
  nullable    = false
}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository allowed to run the deployment workflow."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repository_id))
    error_message = "github_repository_id must contain only digits."
  }
}

variable "github_environment" {
  description = "GitHub Environment required by the deployment job."
  type        = string
  default     = "dev"
  nullable    = false
}

variable "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions through OIDC."
  type        = string
  nullable    = false
}

variable "state_bucket_name" {
  description = "S3 bucket name used by Terraform for remote state."
  type        = string
  nullable    = false
}

variable "lock_table_name" {
  description = "DynamoDB table name used by Terraform for state locking."
  type        = string
  nullable    = false
}

variable "tags" {
  description = "Common tags applied to IAM resources."
  type        = map(string)
  default     = {}
}
