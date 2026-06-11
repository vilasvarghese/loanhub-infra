output "backend_uri" {
  description = "ECR URI for the backend image (used as ECR_BACKEND_URI GitHub secret)"
  value       = aws_ecr_repository.this["loanhub-backend"].repository_url
}

output "frontend_uri" {
  description = "ECR URI for the frontend image (used as ECR_FRONTEND_URI GitHub secret)"
  value       = aws_ecr_repository.this["loanhub-frontend"].repository_url
}
