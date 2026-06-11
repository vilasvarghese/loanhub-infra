provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
      Project     = "loanhub"
      Environment = var.environment
      ManagedBy   = "terraform"
    }
  }
}
