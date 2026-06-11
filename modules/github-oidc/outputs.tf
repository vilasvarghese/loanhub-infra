output "role_arn" {
  description = "ARN of the CI role — set this as the AWS_ROLE_ARN GitHub secret"
  value       = aws_iam_role.github_ci.arn
}
