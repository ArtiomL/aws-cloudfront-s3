# Infrastructure

locals {
  tags = {
    CreatedBy   = "Terraform"
    Environment = "${var.tag_environment}"
  }
}

provider "aws" {
  region = "${var.aws_region}"
}

provider "aws" {
  alias  = "acm"
  region = "us-east-1"
}

# S3 bucket
resource "aws_s3_bucket" "main" {
  bucket        = "${var.domain_name}"
  acl           = "private"
  force_destroy = "${var.force_destroy}"

  tags = "${merge(local.tags, var.tags_shared, map(
    "Name", "buck${var.tag_name}${var.tag_environment}"
  ))}"
}

resource "aws_s3_bucket_public_access_block" "main" {
  bucket                  = "${aws_s3_bucket.main.id}"
  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_policy" "main" {
  bucket = "${aws_s3_bucket.main.id}"
  policy = "${data.aws_iam_policy_document.main.json}"
}

# IAM
data "aws_iam_policy_document" "main" {
  statement {
    sid    = "CloudFrontOAItoS3"
    effect = "Allow"

    principals {
      type        = "AWS"
      identifiers = ["${aws_cloudfront_origin_access_identity.main.iam_arn}"]
    }

    actions   = ["s3:GetObject"]
    resources = ["arn:aws:s3:::${var.domain_name}${var.origin_path}/*"]
  }
}

# CloudFront
resource "aws_cloudfront_origin_access_identity" "main" {
  comment = "Access ${var.domain_name} S3 bucket content only through CloudFront"
}

resource "aws_cloudfront_distribution" "main" {
  origin {
    domain_name = "${aws_s3_bucket.main.bucket_regional_domain_name}"
    origin_id   = "${aws_s3_bucket.main.bucket_regional_domain_name}"
    origin_path = "${var.origin_path}"

    s3_origin_config {
      origin_access_identity = "${aws_cloudfront_origin_access_identity.main.cloudfront_access_identity_path}"
    }
  }

  enabled             = "${var.enabled}"
  is_ipv6_enabled     = "${var.is_ipv6_enabled}"
  comment             = "${var.comment}"
  default_root_object = "${var.default_root_object}"
  price_class         = "${var.price_class}"

  aliases = ["${var.domain_name}"]

  default_cache_behavior {
    allowed_methods  = "${var.allowed_methods}"
    cached_methods   = "${var.cached_methods}"
    target_origin_id = "${aws_s3_bucket.main.bucket_regional_domain_name}"
    compress         = "${var.compress}"

    forwarded_values {
      query_string = false

      cookies {
        forward = "none"
      }
    }

    viewer_protocol_policy = "${var.viewer_protocol_policy}"
    default_ttl            = "${var.default_ttl}"
    min_ttl                = "${var.min_ttl}"
    max_ttl                = "${var.max_ttl}"
  }

  restrictions {
    geo_restriction {
      restriction_type = "${var.geo_restriction_type}"
      locations        = "${var.geo_restriction_locations}"
    }
  }

  viewer_certificate {
    acm_certificate_arn            = "${aws_acm_certificate.main.arn}"
    ssl_support_method             = "sni-only"
    minimum_protocol_version       = "${var.minimum_protocol_version}"
    cloudfront_default_certificate = false
  }

  wait_for_deployment = "${var.wait_for_deployment}"

  tags = "${merge(local.tags, var.tags_shared, map(
    "Name", "dist${var.tag_name}${var.tag_environment}"
  ))}"
}

resource "aws_acm_certificate" "main" {
  provider          = "aws.acm"
  domain_name       = "${var.domain_name}"
  validation_method = "DNS"

  lifecycle {
    create_before_destroy = true
  }

  tags = "${merge(local.tags, var.tags_shared, map(
    "Name", "cert${var.tag_name}${var.tag_environment}"
  ))}"
}

resource "aws_route53_record" "acm" {
  provider = "aws.acm"
  zone_id  = "${var.zone_id}"
  name     = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_name}"
  ttl      = 60
  type     = "${aws_acm_certificate.main.domain_validation_options.0.resource_record_type}"
  records  = ["${aws_acm_certificate.main.domain_validation_options.0.resource_record_value}"]
}

resource "aws_acm_certificate_validation" "main" {
  provider                = "aws.acm"
  certificate_arn         = "${aws_acm_certificate.main.arn}"
  validation_record_fqdns = ["${aws_route53_record.acm.fqdn}"]
}

# DNS records
resource "aws_route53_record" "main" {
  zone_id = "${var.zone_id}"
  name    = "${var.domain_name}"
  type    = "A"

  alias {
    name                   = "${aws_cloudfront_distribution.main.domain_name}"
    zone_id                = "${aws_cloudfront_distribution.main.hosted_zone_id}"
    evaluate_target_health = false
  }
}
