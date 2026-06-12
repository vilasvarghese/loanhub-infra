module "eks" {
  source  = "terraform-aws-modules/eks/aws"
  version = "~> 20.0"

  cluster_name    = local.name
  cluster_version = "1.30"

  vpc_id     = module.vpc.vpc_id
  subnet_ids = module.vpc.private_subnets

  cluster_endpoint_public_access  = true
  cluster_endpoint_private_access = true

  # ── EKS Managed Node Group ────────────────────────────────────────────────
  eks_managed_node_groups = {
    default = {
      name           = "${local.name}-nodes"
      instance_types = [var.environment == "prod" ? "t3.large" : "t3.medium"]

      min_size     = var.environment == "prod" ? 2 : 1
      max_size     = var.environment == "prod" ? 6 : 4
      desired_size = var.environment == "prod" ? 3 : 2

      update_config = {
        max_unavailable = 1
      }
    }
  }

  # ── Cluster Add-ons ──────────────────────────────────────────────────────
  cluster_addons = {
    vpc-cni = {
      most_recent                 = true
      resolve_conflicts_on_update = "OVERWRITE"
    }
    coredns = {
      most_recent                 = true
      resolve_conflicts_on_update = "OVERWRITE"
    }
    kube-proxy = {
      most_recent                 = true
      resolve_conflicts_on_update = "OVERWRITE"
    }
    aws-ebs-csi-driver = {
      most_recent                 = true
      resolve_conflicts_on_update = "OVERWRITE"
      service_account_role_arn    = module.ebs_csi_irsa.iam_role_arn
    }
  }

  # Let the module create the OIDC provider for IRSA
  enable_irsa = true

  tags = {
    Environment = var.environment
    Project     = "loanhub"
  }
}

# ── IRSA: EBS CSI Driver ──────────────────────────────────────────────────────
module "ebs_csi_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name             = "${local.name}-ebs-csi-role"
  attach_ebs_csi_policy = true

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["kube-system:ebs-csi-controller-sa"]
    }
  }

  tags = { Environment = var.environment }
}

# ── IRSA: External Secrets Operator ───────────────────────────────────────────
module "eso_irsa" {
  source  = "terraform-aws-modules/iam/aws//modules/iam-role-for-service-accounts-eks"
  version = "~> 5.0"

  role_name = "${local.name}-eso-role"

  oidc_providers = {
    main = {
      provider_arn               = module.eks.oidc_provider_arn
      namespace_service_accounts = ["external-secrets:external-secrets"]
    }
  }

  role_policy_arns = {
    eso_secrets = aws_iam_policy.eso_secrets.arn
  }

  tags = { Environment = var.environment }
}

# ESO needs read access to Secrets Manager
resource "aws_iam_policy" "eso_secrets" {
  name        = "${local.name}-eso-secrets"
  description = "Allow ESO to read loanhub secrets from Secrets Manager"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue",
          "secretsmanager:DescribeSecret"
        ]
        Resource = "arn:aws:secretsmanager:${var.aws_region}:${data.aws_caller_identity.current.account_id}:secret:loanhub/*"
      }
    ]
  })
}
