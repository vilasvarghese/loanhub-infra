output "db_host" {
  value = aws_db_instance.this.address
}

output "db_name" {
  value = local.db_name
}

output "db_secret_arn" {
  description = "ARN of the Secrets Manager secret holding the DB credentials (used by External Secrets Operator)"
  value       = aws_secretsmanager_secret.db.arn
}
