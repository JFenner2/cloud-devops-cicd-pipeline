resource "aws_ssm_document" "deploy" {
  name            = "cloud-devops-cicd-deploy"
  document_type   = "Command"
  document_format = "JSON"

  content = jsonencode({
    schemaVersion = "2.2"
    description   = "Deploy a versioned ECR image to the application EC2 instance"

    parameters = {
      imageUri = {
        type        = "String"
        description = "Complete ECR image URI including the immutable commit SHA tag"
        allowedPattern = join("", [
          "^[0-9]{12}\\.dkr\\.ecr\\.",
          "[a-z0-9-]+\\.amazonaws\\.com/",
          "cloud-devops-cicd-pipeline:",
          "[a-f0-9]{40}$"
        ])
      }
    }

    mainSteps = [
      {
        action = "aws:runShellScript"
        name   = "deployContainer"

        inputs = {
          timeoutSeconds = "600"

          runCommand = [
            "set -euo pipefail",
            "IMAGE_URI='{{ imageUri }}'",
            "REGISTRY=$(echo \"$IMAGE_URI\" | cut -d/ -f1)",
            "echo \"Deploying $IMAGE_URI\"",
            "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin \"$REGISTRY\"",
            "docker pull \"$IMAGE_URI\"",
            "docker rm -f cloud-devops-app || true",
            "docker run -d --name cloud-devops-app --restart unless-stopped -p 80:80 \"$IMAGE_URI\"",
            "for attempt in $(seq 1 12); do",
            "  if curl --fail --silent http://localhost/ | grep --quiet 'Cloud DevOps CI/CD Pipeline'; then",
            "    echo 'Application health check passed'",
            "    exit 0",
            "  fi",
            "  echo \"Health check attempt $attempt failed; retrying...\"",
            "  sleep 5",
            "done",
            "echo 'Application failed its health check'",
            "docker logs cloud-devops-app",
            "exit 1"
          ]
        }
      }
    ]
  })

  tags = {
    Name = "cloud-devops-cicd-deploy"
  }
}
