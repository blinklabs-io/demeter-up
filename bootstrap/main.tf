locals {
  default_vars = yamldecode(file("../common/defaults.yaml"))
  config_vars  = try(yamldecode(file("../config.yaml")), {})

  cloud_provider = try(
    local.config_vars.cloud_provider,
    local.default_vars.cloud_provider,
    "aws",
  )
  region = try(
    local.config_vars.metadata.region,
    local.config_vars.region,
    local.default_vars.metadata.region,
    "us-west-2"
  )
  tags = try(
    local.config_vars.tags,
    local.default_vars.tags,
    {}
  )
}

# Configure our AWS provider
provider "aws" {
  region = local.region
}

# Create a dynamodb table for storing terraform state locks
resource "aws_dynamodb_table" "this" {
  for_each = toset([for t in toset(["terraform-state-lock"]) : t if local.cloud_provider == "aws"])

  name         = each.key
  hash_key     = "LockID"
  billing_mode = "PAY_PER_REQUEST"

  attribute {
    name = "LockID"
    type = "S"
  }

  tags = merge(
    { "Name" = each.key },
    local.tags
  )
}

# Create an IAM user for running terraform and grant it IAMFullAccess and
# PowerUserAccess policies
resource "aws_iam_user" "this" {
  for_each = toset([for u in toset(["terraform-service-account"]) : u if local.cloud_provider == "aws"])

  name = each.key
  tags = local.tags
}

resource "aws_iam_user_policy_attachment" "this" {
  for_each = {
    for p in toset(["IAMFullAccess", "PowerUserAccess"]) : "terraform-service-account|policy|${p}" => {
      policy_arn = "arn:aws:iam::aws:policy/${p}",
      user       = "terraform-service-account",
    } if local.cloud_provider == "aws"
  }

  policy_arn = each.value.policy_arn
  user       = aws_iam_user.this[each.value.user].name
}

# Create a KMS key and alias for encrypting terraform state
resource "aws_kms_key" "this" {
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  deletion_window_in_days = 14
  description             = "KMS Key used to encrypt terraform state S3 bucket"
  tags                    = local.tags
}

resource "aws_kms_alias" "this" {
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  target_key_id = aws_kms_key.this[each.key].key_id
  name          = "alias/${each.key}"
}

# Generate a random identifier
resource "random_id" "this" {
  byte_length = 8
}

# Create an S3 bucket with versioning for our state
resource "aws_s3_bucket" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = "${random_id.this.hex}-${each.key}"
  tags = merge(
    { "Name" : "${random_id.this.hex}-${each.key}" },
    local.tags,
  )
}

resource "aws_s3_bucket_ownership_controls" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this["${random_id.this.hex}-${each.key}"].id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }
}

resource "aws_s3_bucket_public_access_block" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this["${random_id.this.hex}-${each.key}"].id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_acl" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  depends_on = [
    aws_s3_bucket_ownership_controls.this,
    aws_s3_bucket_public_access_block.this,
  ]

  bucket = aws_s3_bucket.this["${random_id.this.hex}-${each.key}"].id
  acl    = "private"
}

resource "aws_s3_bucket_server_side_encryption_configuration" "this" {
  # This loop uses the KMS key identifier
  for_each = toset([for k in toset(["terraform-state"]) : k if local.cloud_provider == "aws"])

  bucket = aws_s3_bucket.this["${random_id.this.hex}-${each.key}"].id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = aws_kms_key.this[each.key].arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_versioning" "this" {
  for_each = toset([for b in toset(["terraform-state"]) : b if local.cloud_provider == "aws"])

  depends_on = [
    aws_s3_bucket_acl.this,
    aws_s3_bucket_server_side_encryption_configuration.this,
  ]

  bucket = aws_s3_bucket.this["${random_id.this.hex}-${each.key}"].id
  versioning_configuration {
    status = "Enabled"
  }
}

output "terraform_state_bucket" {
  value = join(",", values(aws_s3_bucket.this)[*].id)
}

output "region" {
  value = local.region
}

terraform {
  required_version = ">= 1.0.3, < 2.0.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "5.31.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "3.6.0"
    }
  }
}
