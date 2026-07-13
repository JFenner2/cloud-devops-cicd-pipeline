output "ecr_repository_name" {
  description = "Name of the ECR repository"
  value       = aws_ecr_repository.app.name
}

output "ecr_repository_url" {
  description = "URL used to push and pull Docker images"
  value       = aws_ecr_repository.app.repository_url
}

output "aws_region" {
  description = "AWS region containing the regional resources"
  value       = var.aws_region
}
output "github_actions_role_arn" {
  description = "IAM role ARN that GitHub Actions will assume through OIDC"
  value       = aws_iam_role.github_actions.arn
}
