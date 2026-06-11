data "aws_caller_identity" "current" {}

# ── GitHub OIDC provider (one per AWS account) ─────────────────────────────────
resource "aws_iam_openid_connect_provider" "github" {
  url            = "https://token.actions.githubusercontent.com"
  client_id_list = ["sts.amazonaws.com"]
  # GitHub's current OIDC thumbprint — stable, updated by GitHub when rotated
  thumbprint_list = ["6938fd4d98bab03faadb97b34396831e3780aea1"]
}

# ── Trust policy: only raj-pro repos on main branch can assume this role ───────
data "aws_iam_policy_document" "github_assume" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.github.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "token.actions.githubusercontent.com:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      # Lock down to specific repos and the main branch only
      test     = "StringLike"
      variable = "token.actions.githubusercontent.com:sub"
      values = [
        "repo:raj-pro/loanhub-backend:ref:refs/heads/main",
        "repo:raj-pro/loanhub-frontend:ref:refs/heads/main",
      ]
    }
  }
}

resource "aws_iam_role" "github_ci" {
  name               = "loanhub-github-ci"
  assume_role_policy = data.aws_iam_policy_document.github_assume.json
  description        = "Assumed by GitHub Actions (OIDC) to push images to ECR"
}

# ── ECR push permissions ───────────────────────────────────────────────────────
data "aws_iam_policy_document" "ecr_push" {
  statement {
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]
  }
  statement {
    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
      "ecr:InitiateLayerUpload",
      "ecr:UploadLayerPart",
      "ecr:CompleteLayerUpload",
      "ecr:PutImage",
    ]
    resources = [
      "arn:aws:ecr:${var.aws_region}:${data.aws_caller_identity.current.account_id}:repository/loanhub-*"
    ]
  }
}

resource "aws_iam_policy" "ecr_push" {
  name   = "loanhub-ecr-push"
  policy = data.aws_iam_policy_document.ecr_push.json
}

resource "aws_iam_role_policy_attachment" "ecr_push" {
  role       = aws_iam_role.github_ci.name
  policy_arn = aws_iam_policy.ecr_push.arn
}
