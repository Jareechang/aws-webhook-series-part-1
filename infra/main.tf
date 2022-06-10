# Infrastructure definitions

provider "aws" {
  version = "~> 2.0"
  region  = var.aws_region
}

# Local vars
locals {
  default_lambda_timeout = 10

  default_lambda_log_retention = 1
}

resource "aws_s3_bucket" "lambda_bucket" {
  bucket        = "lambda-bucket-assets-1234567"
  acl           = "private"
}

module "lambda_ingestion" {
  source               = "./modules/lambda"
  code_src             = "../functions/ingestion/main.zip"
  bucket_id            = aws_s3_bucket.lambda_bucket.id
  timeout              = local.default_lambda_timeout
  function_name        = "Ingestion-function"
  runtime              = "nodejs12.x"
  handler              = "dist/index.handler"
  publish              = true
  alias_name           = "ingestion-dev"
  alias_description    = "Alias for ingestion function"
  environment_vars = {
    DefaultRegion   = var.aws_region
  }
}

module "lambda_process_queue" {
  source               = "./modules/lambda"
  code_src             = "../functions/process-queue/main.zip"
  bucket_id            = aws_s3_bucket.lambda_bucket.id
  timeout              = local.default_lambda_timeout
  function_name        = "Process-Queue-function"
  runtime              = "nodejs12.x"
  handler              = "dist/index.handler"
  publish              = true
  alias_name           = "process-queue-dev"
  alias_description    = "Alias for ingestion function"
  environment_vars = {
    DefaultRegion   = var.aws_region
  }
}
