# ---------------------------------------------------------------------------
# SSM VPC Interface Endpoints
#
# SSM (AWS Systems Manager) is a regional service — there is nothing to
# "create" for the service itself. What this provides is the NETWORK PATH so
# nodes in PRIVATE subnets can reach SSM without relying on the NAT gateway.
#
# Three endpoints are required for Session Manager to work:
#   - ssm          : core SSM API
#   - ssmmessages  : Session Manager data channel
#   - ec2messages  : agent <-> SSM message bus
# ---------------------------------------------------------------------------

locals {
  ssm_endpoints = ["ssm", "ssmmessages", "ec2messages"]
}

# Security group allowing HTTPS from inside the VPC to the endpoints
resource "aws_security_group" "ssm_endpoints" {
  name        = "${local.name}-ssm-endpoints"
  description = "Allow HTTPS from VPC to SSM interface endpoints"
  vpc_id      = module.vpc.vpc_id

  ingress {
    description = "HTTPS from VPC"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [var.vpc_cidr]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Environment = var.environment
    Project     = "loanhub"
  }
}

resource "aws_vpc_endpoint" "ssm" {
  for_each = toset(local.ssm_endpoints)

  vpc_id              = module.vpc.vpc_id
  service_name        = "com.amazonaws.${var.aws_region}.${each.value}"
  vpc_endpoint_type   = "Interface"
  subnet_ids          = module.vpc.private_subnets
  security_group_ids  = [aws_security_group.ssm_endpoints.id]
  private_dns_enabled = true

  tags = {
    Name        = "${local.name}-${each.value}"
    Environment = var.environment
  }
}
