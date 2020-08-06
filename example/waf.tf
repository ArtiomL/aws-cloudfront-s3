# WAFv2
provider "aws" {
  alias  = "us_east_1"
  region = "us-east-1"
}

resource "aws_wafv2_web_acl" "main" {
  provider    = aws.us_east_1
  name        = "wacl${var.tag_name}${var.tag_environment}"
  description = "AWS WAF Web ACL for ${var.tag_name}${var.tag_environment}"
  scope       = "CLOUDFRONT"

  default_action {
    allow {}
  }

  rule {
    name     = "amwrAmazonIpReputationList"
    priority = 0

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAmazonIpReputationList"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrAmazonIpReputationList"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "amwrAdminProtection"
    priority = 1

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesAdminProtectionRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrAdminProtection"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "amwrKnownBadInputs"
    priority = 2

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesKnownBadInputsRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrKnownBadInputs"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "amwrSQLi"
    priority = 3

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesSQLiRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrSQLi"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "amwrLinux"
    priority = 4

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesLinuxRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrLinux"
      sampled_requests_enabled   = true
    }
  }

  rule {
    name     = "amwrCommon"
    priority = 5

    override_action {
      none {}
    }

    statement {
      managed_rule_group_statement {
        name        = "AWSManagedRulesCommonRuleSet"
        vendor_name = "AWS"
      }
    }

    visibility_config {
      cloudwatch_metrics_enabled = true
      metric_name                = "amwrCommon"
      sampled_requests_enabled   = true
    }
  }

  tags = merge(
    local.tags,
    var.tags_shared,
    {
      "Name" = "wacl${var.tag_name}${var.tag_environment}"
    },
  )

  visibility_config {
    cloudwatch_metrics_enabled = true
    metric_name                = "wacl${var.tag_name}${var.tag_environment}"
    sampled_requests_enabled   = true
  }
}