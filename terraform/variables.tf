variable "aws_region" {
  description = "AWS region in which regional resources will be created"
  type        = string
  default     = "ap-southeast-2"
}

variable "github_owner" {
  description = "GitHub username or organisation that owns the repository"
  type        = string
  default     = "JFenner2"
}

variable "github_repository" {
  description = "GitHub repository authorised to assume the AWS IAM role"
  type        = string
  default     = "cloud-devops-cicd-pipeline"
}
variable "github_branch" {
  description = "GitHub branch authorised to assume the AWS IAM role"
  type        = string
  default     = "main"
}
