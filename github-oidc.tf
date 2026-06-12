# ── GitHub OIDC Provider (one per AWS account) ───────────────────────────────
module "github_oidc_provider" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-provider"
  version = "~> 5.0"

  tags = { Environment = var.environment }
}

# ── CI Role assumed by GitHub Actions ─────────────────────────────────────────
module "github_oidc_role" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-github-oidc-role"
  version = "~> 5.0"

  name = "loanhub-github-ci"

  subjects = [
    "repo:${var.github_org}/loanhub-backend:ref:refs/heads/main",
    "repo:${var.github_org}/loanhub-frontend:ref:refs/heads/main",
  ]

  policies = {
    ecr_push = aws_iam_policy.ecr_push.arn
  }

  tags = {
    Environment = var.environment
    Project     = "loanhub"
  }
}

# ── ECR push permissions ─────────────────────────────────────────────────────
resource "aws_iam_policy" "ecr_push" {
  name        = "loanhub-ecr-push"
  description = "Allow GitHub CI to push images to loanhub ECR repos"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = ["ecr:GetAuthorizationToken"]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:BatchGetImage",
          "ecr:InitiateLayerUpload",
          "ecr:UploadLayerPart",
          "ecr:CompleteLayerUpload",
          "ecr:PutImage"
        ]
        Resource = "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/loanhub-*"
      }
    ]
  })
}
