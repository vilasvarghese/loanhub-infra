locals {
  db_identifier = local.name
  db_name       = replace(local.name, "-", "_")
}

# ── Random password → Secrets Manager ─────────────────────────────────────────
resource "random_password" "db" {
  length           = 32
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_secretsmanager_secret" "db" {
  name                    = "loanhub/${local.db_identifier}/db-password"
  description             = "RDS master password for ${local.db_identifier}"
  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "db" {
  secret_id = aws_secretsmanager_secret.db.id
  secret_string = jsonencode({
    username = var.db_username
    password = random_password.db.result
    host     = module.rds.db_instance_address
    port     = 5432
    dbname   = local.db_name
  })
}

# ── Security group for RDS ────────────────────────────────────────────────────
module "rds_sg" {
  source  = "terraform-aws-modules/security-group/aws"
  version = "~> 5.0"

  name        = "${local.db_identifier}-rds-sg"
  description = "Allow PostgreSQL traffic from EKS backend pods"
  vpc_id      = module.vpc.vpc_id

  ingress_with_cidr_blocks = [
    {
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "PostgreSQL from VPC"
      cidr_blocks = var.vpc_cidr
    }
  ]

  egress_with_cidr_blocks = [
    {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = "0.0.0.0/0"
    }
  ]

  tags = { Environment = var.environment }
}

# ── RDS PostgreSQL ────────────────────────────────────────────────────────────

module "rds" {
  source  = "terraform-aws-modules/rds/aws"
  version = "~> 6.0"

  identifier = local.db_identifier

  engine               = "postgres"
  engine_version       = "16"
  family               = "postgres16"
  major_engine_version = "16"
  instance_class       = var.environment == "prod" ? "db.t3.small" : "db.t3.micro"

  allocated_storage = 20
  storage_encrypted = true

  db_name  = local.db_name
  username = var.db_username
  password = random_password.db.result
  port     = 5432

  # Use our own random_password (stored in Secrets Manager + read by ESO)
  # instead of letting RDS manage its own master-user secret.
  manage_master_user_password = false


  multi_az            = var.environment == "prod"
  publicly_accessible = false

  # ── FIX: use the VPC module's database subnet group ──────────────────────
  create_db_subnet_group = false
  db_subnet_group_name   = module.vpc.database_subnet_group_name
  # ─────────────────────────────────────────────────────────────────────────

  vpc_security_group_ids = [module.rds_sg.security_group_id]

  backup_retention_period = var.environment == "prod" ? 7 : 1
  backup_window           = "03:00-04:00"
  maintenance_window      = "Mon:04:00-Mon:05:00"

  skip_final_snapshot = var.environment != "prod"
  deletion_protection = var.environment == "prod"

  tags = {
    Environment = var.environment
    Project     = "loanhub"
  }
}
