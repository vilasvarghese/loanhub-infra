# loanhub-infra

Terraform IaC for the LoanHub platform on **AWS**. Provisions the network, the managed
Kubernetes cluster, the database, and the container registry.

Part of the LoanHub polyrepo:
[`loanhub-backend`](https://github.com/raj-pro/loanhub-backend) ·
[`loanhub-frontend`](https://github.com/raj-pro/loanhub-frontend) ·
[`loanhub-infra`](https://github.com/raj-pro/loanhub-infra) ·
[`loanhub-gitops`](https://github.com/raj-pro/loanhub-gitops)

## Target topology (Phase 4/5)

| Module | Resource |
|--------|----------|
| `vpc`  | VPC, public/private subnets, route tables, NAT, security groups |
| `eks`  | EKS cluster + managed node group, IRSA/OIDC provider |
| `rds`  | PostgreSQL (Multi-AZ), subnet group, password → Secrets Manager |
| `ecr`  | Container registries for backend + frontend images |

## Layout (current = Phase 1 skeleton)

```
infra/
├── versions.tf     # terraform + AWS provider version constraints
├── providers.tf    # AWS provider + default tags
├── variables.tf    # region, environment
├── backend.tf      # S3 + DynamoDB remote state (commented until bootstrapped)
└── modules/        # vpc / eks / rds / ecr  (added in Phase 4)
```

## Getting started

```sh
terraform fmt -recursive
terraform init -backend=false   # local state until remote backend is bootstrapped
terraform validate
```

## Remote state bootstrap (one-time)

The S3 state bucket and DynamoDB lock table must exist before enabling the S3
backend in `backend.tf`:

1. Create an encrypted, versioned S3 bucket `loanhub-tfstate-<AWS_ACCOUNT_ID>`.
2. Create a DynamoDB table `loanhub-tfstate-lock` with a `LockID` (string) hash key.
3. Uncomment the `backend "s3"` block in `backend.tf` and run `terraform init -migrate-state`.

State is encrypted at rest (S3) and locked on every apply (DynamoDB) to prevent
concurrent-modification races.
