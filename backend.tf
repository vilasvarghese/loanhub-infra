# ---------------------------------------------------------------------------
# Remote state backend — S3 for storage, DynamoDB for state locking.
#
# Chicken-and-egg: the bucket and lock table must exist BEFORE this is enabled.
# Bootstrap them once (see README → "Remote state bootstrap"), then uncomment
# and run:  terraform init -migrate-state
# ---------------------------------------------------------------------------
# terraform {
#   backend "s3" {
#     bucket         = "loanhub-tfstate-<AWS_ACCOUNT_ID>"
#     key            = "loanhub/eks/terraform.tfstate"
#     region         = "ap-south-1"
#     dynamodb_table = "loanhub-tfstate-lock"
#     encrypt        = true
#   }
# }
