module "vpc" {
  source  = "terraform-aws-modules/vpc/aws"
  version = "~> 5.0"

  name = "${local.name}-vpc"
  cidr = var.vpc_cidr
  azs  = local.azs

  public_subnets  = local.public_subnets
  private_subnets = local.private_subnets

  # ── ADD these two lines ──────────────────────────────────────────────────
  database_subnets              = [for i in range(length(local.azs)) : cidrsubnet(var.vpc_cidr, 4, i + 2 * length(local.azs))]
  create_database_subnet_group  = true
  # ─────────────────────────────────────────────────────────────────────────

  enable_nat_gateway     = true
  single_nat_gateway     = var.environment == "dev"
  one_nat_gateway_per_az = var.environment == "prod"

  enable_dns_hostnames = true
  enable_dns_support   = true

  public_subnet_tags = {
    "kubernetes.io/role/elb" = "1"
  }

  private_subnet_tags = {
    "kubernetes.io/role/internal-elb" = "1"
  }

  tags = {
    Environment = var.environment
    Project     = "loanhub"
  }
}
