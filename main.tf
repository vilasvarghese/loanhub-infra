module "vpc" {
  source   = "./modules/vpc"
  name     = "loanhub-${var.environment}"
  vpc_cidr = "10.0.0.0/16"
}

module "eks" {
  source             = "./modules/eks"
  cluster_name       = "loanhub-${var.environment}"
  private_subnet_ids = module.vpc.private_subnet_ids

  # dev: t3.medium × 2  |  prod: t3.large × 3
  node_instance_type = var.environment == "prod" ? "t3.large" : "t3.medium"
  node_desired       = var.environment == "prod" ? 3 : 2
  node_min           = var.environment == "prod" ? 2 : 1
  node_max           = var.environment == "prod" ? 6 : 4
}

module "rds" {
  source             = "./modules/rds"
  identifier         = "loanhub-${var.environment}"
  vpc_id             = module.vpc.vpc_id
  vpc_cidr           = "10.0.0.0/16"
  private_subnet_ids = module.vpc.private_subnet_ids

  instance_class = var.environment == "prod" ? "db.t3.small" : "db.t3.micro"
  multi_az       = var.environment == "prod"
}

module "ecr" {
  source = "./modules/ecr"
}

module "github_oidc" {
  source     = "./modules/github-oidc"
  aws_region = var.aws_region
}
