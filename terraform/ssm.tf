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
            "STATE_DIRECTORY='/var/lib/cloud-devops'",
            "STATE_FILE=\"$STATE_DIRECTORY/current-image\"",
            "mkdir -p \"$STATE_DIRECTORY\"",
            "PREVIOUS_IMAGE=''",
            "if [ -f \"$STATE_FILE\" ]; then",
            "  PREVIOUS_IMAGE=$(cat \"$STATE_FILE\")",
            "fi",
            "echo \"New image: $IMAGE_URI\"",
            "echo \"Previous image: $${PREVIOUS_IMAGE:-none}\"",

            "rollback() {",
            "  echo 'Starting rollback...'",
            "  docker rm -f cloud-devops-app || true",
            "  if [ -z \"$PREVIOUS_IMAGE\" ]; then",
            "    echo 'No previous successful image is available for rollback'",
            "    exit 1",
            "  fi",
            "  docker pull \"$PREVIOUS_IMAGE\" || true",
            "  if ! docker run -d --name cloud-devops-app --restart unless-stopped -p 80:80 \"$PREVIOUS_IMAGE\"; then",
            "    echo 'The previous container could not be restarted'",
            "    exit 1",
            "  fi",
            "  for attempt in $(seq 1 12); do",
            "    if curl --fail --silent http://localhost/ | grep --quiet 'Cloud DevOps CI/CD Pipeline'; then",
            "      echo \"Rollback succeeded: $PREVIOUS_IMAGE is running\"",
            "      exit 1",
            "    fi",
            "    echo \"Rollback health check attempt $attempt failed\"",
            "    sleep 5",
            "  done",
            "  echo 'Rollback container failed its health check'",
            "  docker logs cloud-devops-app || true",
            "  exit 1",
            "}",

            "aws ecr get-login-password --region ${var.aws_region} | docker login --username AWS --password-stdin \"$REGISTRY\"",
            "docker pull \"$IMAGE_URI\"",
            "docker rm -f cloud-devops-app || true",

            "if ! docker run -d --name cloud-devops-app --restart unless-stopped -p 81:80 \"$IMAGE_URI\"; then",
            "  echo 'The new container failed to start'",
            "  rollback",
            "fi",

            "for attempt in $(seq 1 12); do",
            "  if curl --fail --silent http://localhost/ | grep --quiet 'Cloud DevOps CI/CD Pipeline'; then",
            "    echo \"$IMAGE_URI\" > \"$STATE_FILE\"",
            "    echo \"Deployment succeeded: $IMAGE_URI is healthy\"",
            "    exit 0",
            "  fi",
            "  echo \"Deployment health check attempt $attempt failed; retrying...\"",
            "  sleep 5",
            "done",

            "echo 'The new application failed its health check'",
            "docker logs cloud-devops-app || true",
            "rollback"
          ]
        }
      }
    ]
  })

  tags = {
    Name = "cloud-devops-cicd-deploy"
  }
}
