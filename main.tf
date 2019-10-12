# Infrastructure

locals {
  tags = {
    CreatedBy   = "Terraform"
    Environment = var.tag_environment
  }
}

provider "aws" {
  region = var.aws_region
}

provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

# S3 buckets
resource "aws_s3_bucket" "main" {
  bucket        = var.domain_name
  acl           = "private"
  force_destroy = var.force_destroy

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "buck${var.tag_name}${var.tag_environment}"
    },
  )
}

resource "aws_s3_bucket" "logs" {
  bucket        = "${var.domain_name}.logs"
  acl           = "private"
  force_destroy = var.force_destroy

  lifecycle_rule {
    id      = "ExpireLogs"
    enabled = true

    expiration {
      days = var.log_days
    }
  }

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "buckLogs${var.tag_name}${var.tag_environment}"
    },
  )
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = aws_s3_bucket.main.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "logs" {
  bucket                  = aws_s3_bucket.logs.id
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = aws_s3_bucket.main.id
  policy = data.aws_iam_policy_document.main.json
}

# IAM
data "aws_iam_policy_document" "main" {
  statement {
    sid    = "CloudFrontOAItoS3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = [aws_cloudfront_origin_access_identity.main.iam_arn]
    }

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.domain_name}${var.origin_path}/*"]
  }
}

data "aws_iam_policy_document" "lambda" {
  statement {
    sid    = "LambdaEdgeIAMRole"
    effect = "Allow"

    principals {
      type        = "Service"
      identifiers = ["lambda.amazonaws.com", "edgelambda.amazonaws.com"]
    }

    actions = ["sts:AssumeRole"]
  }
}

resource "aws_iam_role" "lambda" {
  name               = "roleLambda${var.tag_name}${var.tag_environment}"
  assume_role_policy = data.aws_iam_policy_document.lambda.json

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "roleLambda${var.tag_name}${var.tag_environment}"
    },
  )
}

resource "aws_iam_role_policy_attachment" "lambda" {
  role       = aws_iam_role.lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

# ACM
resource "aws_acm_certificate" "main" {
  provider          = aws.us_east_1
  domain_name       = var.domain_name
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "cert${var.tag_name}${var.tag_environment}"
    },
  )
}

resource "aws_route53_record" "acm" {
  provider = aws.us_east_1
  zone_id  = var.zone_id
  name     = aws_acm_certificate.main.domain_validation_options[0].resource_record_name
  ttl      = 60
  type     = aws_acm_certificate.main.domain_validation_options[0].resource_record_type
  records  = [aws_acm_certificate.main.domain_validation_options[0].resource_record_value]
}

resource "aws_acm_certificate_validation" "main" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.main.arn
  validation_record_fqdns = [aws_route53_record.acm.fqdn]
}

# CloudFront
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "Access ${var.domain_name} S3 bucket content only through CloudFront"
}

resource "aws_cloudfront_distribution" "main" {
  enabled             = var.enabled
  is_ipv6_enabled     = var.is_ipv6_enabled
  comment             = var.comment
  default_root_object = var.default_root_object
  price_class         = var.price_class
  aliases             = [var.domain_name]

  viewer_certificate {
    acm_certificate_arn            = aws_acm_certificate_validation.main.certificate_arn
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = var.minimum_protocol_version
    cloudfront_default_certificate = false
  }

  logging_config {
    include_cookies = true
    bucket          = aws_s3_bucket.logs.bucket_regional_domain_name
    prefix          = "CFLogs"
  }

  origin {
    domain_name = aws_s3_bucket.main.bucket_regional_domain_name
    origin_path = var.origin_path
    origin_id   = aws_s3_bucket.main.bucket_regional_domain_name

    s3_origin_config {
      origin_access_identity = aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path
    }
  }

  default_cache_behavior {
    allowed_methods  = var.allowed_methods
    cached_methods   = var.cached_methods
    target_origin_id = aws_s3_bucket.main.bucket_regional_domain_name
    compress         = var.compress

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = var.viewer_protocol_policy
    default_ttl            = var.default_ttl
    min_ttl                = var.min_ttl
    max_ttl                = var.max_ttl

    lambda_function_association {
      event_type   = var.event_type
      lambda_arn   = aws_lambda_function.main.qualified_arn
      include_body = var.include_body
    }
  }

  restrictions {
    geo_restriction {
      restriction_type = var.geo_restriction_type
      locations        = var.geo_restriction_locations
    }
  }

  wait_for_deployment = var.wait_for_deployment
  web_acl_id          = var.web_acl_id

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "dist${var.tag_name}${var.tag_environment}"
    },
  )
}

# Lambda@Edge
resource "aws_lambda_function" "main" {
  provider         = aws.us_east_1
  function_name    = "fun${var.tag_name}${var.tag_environment}"
  filename         = data.archive_file.main.output_path
  handler          = var.handler
  runtime          = var.runtime
  publish          = "true"
  role             = aws_iam_role.lambda.arn
  source_code_hash = data.archive_file.main.output_base64sha256

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "fun${var.tag_name}${var.tag_environment}"
    },
  )
}

data "archive_file" "main" {
  type        = "zip"
  source_file = var.source_file == "" ? "${path.module}/index.js" : var.source_file
  output_path = "source.zip"
}

# DNS alias records
resource "aws_route53_record" "main" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

resource "aws_route53_record" "ipv6" {
  zone_id = var.zone_id
  name    = var.domain_name
  type    = "AAAA"

  alias {
    name                   = aws_cloudfront_distribution.main.domain_name
    zone_id                = aws_cloudfront_distribution.main.hosted_zone_id
    evaluate_target_health = false
  }
}

