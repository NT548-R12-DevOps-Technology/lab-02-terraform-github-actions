variable "aws_region" {
  description = "AWS Region in which the backend resources are created."
  type        = string
  default     = "ap-southeast-1"
  nullable    = false
}

variable "project_name" {
  description = "Project name used in backend resource names and tags."
  type        = string
  default     = "terraform-aws-lab"
  nullable    = false
}

variable "environment" {
  description = "Environment name used in backend resource names and tags."
  type        = string
  default     = "dev"
  nullable    = false
}

variable "state_bucket_name" {
  description = "Globally unique S3 bucket name used to store Terraform state."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[a-z0-9][a-z0-9.-]{1,61}[a-z0-9]$", var.state_bucket_name))
    error_message = "state_bucket_name must be 3-63 lowercase characters using letters, digits, dots or hyphens."
  }
}

variable "github_organization" {
  description = "GitHub organization permitted to assume the deployment role."
  type        = string
  default     = "NT548-R12-DevOps-Technology"
  nullable    = false
}

variable "github_organization_id" {
  description = "Immutable numeric ID of the GitHub organization."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+$", var.github_organization_id))
    error_message = "github_organization_id must contain only digits."
  }
}

variable "github_repository" {
  description = "GitHub repository permitted to assume the deployment role."
  type        = string
  default     = "lab-02-terraform-github-actions"
  nullable    = false
}

variable "github_repository_id" {
  description = "Immutable numeric ID of the GitHub repository."
  type        = string
  nullable    = false

  validation {
    condition     = can(regex("^[0-9]+$", var.github_repository_id))
    error_message = "github_repository_id must contain only digits."
  }
}

variable "github_environment" {
  description = "GitHub Environment required to assume the deployment role."
  type        = string
  default     = "dev"
  nullable    = false
}
