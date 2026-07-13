provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project   = "cloud-devops-cicd-pipeline"
      ManagedBy = "Terraform"
    }
  }
}
