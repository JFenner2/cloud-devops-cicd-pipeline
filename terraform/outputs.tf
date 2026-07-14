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
output "ec2_instance_id" {
  description = "ID of the application EC2 instance"
  value       = aws_instance.app.id
}

output "application_url" {
  description = "Public HTTP URL of the application"
  value       = "http://${aws_instance.app.public_ip}"
}

output "security_group_id" {
  description = "Security group attached to the application instance"
  value       = aws_security_group.app.id
}
output "ssm_deployment_document_name" {
  description = "SSM document used by GitHub Actions to deploy the application"
  value       = aws_ssm_document.deploy.name
}
