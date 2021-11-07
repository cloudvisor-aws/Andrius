data "aws_caller_identity" "current" {}

data "aws_secretsmanager_secret" "prometheus" {
  name = "Prometheus-${local.env}"
}

data "aws_secretsmanager_secret_version" "prometheus" {
  secret_id = data.aws_secretsmanager_secret.prometheus.id
}

locals {
  env                = terraform.workspace
  prometheus_url        = var.prometheus_url_map[local.env]
  prometheus_auth       = jsondecode(data.aws_secretsmanager_secret_version.prometheus.secret_string)[var.prometheus_api_key_name]
  integration_bucket = local.env == "prod" ? "cloudvisor-monitoring" : "cloudvisor-monitoring-${local.env}"
  tags = {
    env     = local.env
    project = var.project
  }
}

provider "prometheus" {
  url  = local.prometheus_url
  auth = local.prometheus_auth
}

resource "aws_s3_bucket" "integration_bucket" {
  bucket = local.integration_bucket
  acl    = "public-read"
  versioning {
    enabled = true
  }
  tags = local.tags
}

resource "aws_s3_bucket_object" "integration_stack" {
  bucket = aws_s3_bucket.integration_bucket.id
  key    = "connect.yaml"
  acl    = "public-read"
  source = "${path.root}/files/connect.yaml"
  etag   = filemd5("${path.root}/files/connect.yaml")
}
