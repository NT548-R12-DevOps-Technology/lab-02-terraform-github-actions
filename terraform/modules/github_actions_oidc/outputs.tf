output "role_arn" {
  description = "Set this value as the AWS_ROLE_TO_ASSUME GitHub variable."
  value       = aws_iam_role.github_actions.arn
}

output "role_name" {
  description = "Name of the IAM role assumed by GitHub Actions."
  value       = aws_iam_role.github_actions.name
}
