data "aws_iam_policy_document" "github_actions_ssm" {
  statement {
    sid    = "SendDeploymentCommand"
    effect = "Allow"

    actions = [
      "ssm:SendCommand"
    ]

    resources = [
      aws_ssm_document.deploy.arn,
      aws_instance.app.arn
    ]
  }

  statement {
    sid    = "ReadDeploymentCommandResult"
    effect = "Allow"

    actions = [
      "ssm:GetCommandInvocation",
      "ssm:ListCommandInvocations"
    ]

    resources = ["*"]
  }
}

resource "aws_iam_policy" "github_actions_ssm" {
  name   = "github-actions-ssm-deployment"
  policy = data.aws_iam_policy_document.github_actions_ssm.json
}

resource "aws_iam_role_policy_attachment" "github_actions_ssm" {
  role       = aws_iam_role.github_actions.name
  policy_arn = aws_iam_policy.github_actions_ssm.arn
}
