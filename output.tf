# ── VPC ───────────────────────────────────────────────────────────────────────
output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnets
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnets
}

# ── EKS ───────────────────────────────────────────────────────────────────────
output "eks_cluster_name" {
  description = "EKS cluster name"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  description = "EKS API server endpoint"
  value       = module.eks.cluster_endpoint
}

output "eks_oidc_provider_arn" {
  description = "OIDC provider ARN (for IRSA)"
  value       = module.eks.oidc_provider_arn
}

output "eso_role_arn" {
  description = "IAM role ARN for External Secrets Operator"
  value       = module.eso_irsa.iam_role_arn
}

# ── RDS ───────────────────────────────────────────────────────────────────────
output "rds_endpoint" {
  description = "RDS instance endpoint"
  value       = module.rds.db_instance_endpoint
}

output "rds_secret_arn" {
  description = "Secrets Manager ARN containing DB credentials"
  value       = aws_secretsmanager_secret.db.arn
}

# ── ECR ───────────────────────────────────────────────────────────────────────
output "ecr_repository_urls" {
  description = "Map of ECR repository URLs"
  value       = { for k, v in module.ecr : k => v.repository_url }
}

# ── GitHub OIDC ───────────────────────────────────────────────────────────────
output "github_ci_role_arn" {
  description = "IAM role ARN for GitHub Actions OIDC"
  value       = module.github_oidc_role.arn
}
