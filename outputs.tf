# ── GitHub Secrets — copy these values after `terraform apply` ─────────────────
output "AWS_ROLE_ARN" {
  description = "Set as GitHub secret AWS_ROLE_ARN in loanhub-backend and loanhub-frontend"
  value       = module.github_oidc.role_arn
}

output "ECR_BACKEND_URI" {
  description = "Set as GitHub secret ECR_BACKEND_URI"
  value       = module.ecr.backend_uri
}

output "ECR_FRONTEND_URI" {
  description = "Set as GitHub secret ECR_FRONTEND_URI"
  value       = module.ecr.frontend_uri
}

# ── K8s / ArgoCD wiring ────────────────────────────────────────────────────────
output "eks_cluster_name" {
  description = "Used in: aws eks update-kubeconfig --name <value>"
  value       = module.eks.cluster_name
}

output "eks_cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "rds_host" {
  description = "Set in the K8s ConfigMap (loanhub-gitops/base/backend/configmap.yaml)"
  value       = module.rds.db_host
}

output "rds_db_secret_arn" {
  description = "Set in the ExternalSecret (loanhub-gitops/base/backend/externalsecret.yaml)"
  value       = module.rds.db_secret_arn
}
