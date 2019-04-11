# Input Variables

variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

# S3
variable "force_destroy" {
  description = "All objects should be deleted from the bucket so that the bucket can be destroyed without error"
  default     = "true"
}

# DNS
variable "domain_name" {
  description = "DNS domain name"
}

variable "zone_id" {
  description = "Route 53 zone ID"
}

# CloudFront
variable "enabled" {
  description = "Whether the distribution is enabled to accept end user requests for content"
  default     = "true"
}

variable "is_ipv6_enabled" {
  description = "Whether IPv6 is enabled for the distribution"
  default     = "true"
}

variable "minimum_protocol_version" {
  description = "The minimum TLS version that you want CloudFront to use for HTTPS connections"
  default     = "TLSv1_2016"
}

variable "origin_path" {
  description = "Causes CloudFront to request content from a directory in your S3 bucket"
  default     = ""
}

variable "compress" {
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
  default     = "true"
}

variable "default_root_object" {
  description = "An object CloudFront returns when the end user requests the root URL"
  default     = "index.html"
}

variable "comment" {
  description = "Distribution comments"
  default     = "Managed by Terraform"
}

variable "price_class" {
  description = "The price class for this distribution (PriceClass_All, PriceClass_200, PriceClass_100)"
  default     = "PriceClass_All"
}

variable "viewer_protocol_policy" {
  description = "The protocol users can use to access the origin files (allow-all, https-only, redirect-to-https)"
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  description = "Controls which HTTP methods CloudFront processes and forwards to your S3 bucket"
  type        = "list"
  default     = ["GET", "HEAD"]
}

variable "cached_methods" {
  description = "Controls whether CloudFront caches responses to requests using the specified HTTP methods"
  type        = "list"
  default     = ["GET", "HEAD"]
}

variable "default_ttl" {
  description = "Default amount of time (in seconds) an object is in a CloudFront cache"
  default     = "3600"
}

variable "min_ttl" {
  description = "Minimum amount of time you want objects to stay in CloudFront caches"
  default     = "0"
}

variable "max_ttl" {
  description = "Maximum amount of time an object is in a CloudFront cache"
  default     = "86400"
}

variable "geo_restriction_type" {
  description = "The method to restrict distribution of your content by country (none, whitelist, blacklist)"
  default     = "none"
}

variable "geo_restriction_locations" {
  description = "ISO 3166-1-alpha-2 country codes"
  type        = "list"
  default     = []
}

variable "wait_for_deployment" {
  description = "Wait for the distribution status to change from InProgress to Deployed"
  default     = "false"
}

# Lambda@Edge
variable "source_file" {
  description = "Package this file into the function archive (index.js local to the module path is used by default)"
  default     = ""
}

variable "handler" {
  description = "The function entrypoint in your code"
  default     = "index.handler"
}

variable "runtime" {
  description = "Function runtime identifier"
  default     = "nodejs8.10"
}

variable "event_type" {
  description = "The specific event to trigger the function"
  default     = "origin-response"
}

variable "include_body" {
  description = "Expose the request body to the Lambda function"
  default     = "false"
}

# Tags
variable "tag_name" {
  description = "Name tag"
  default     = "AWSLabs"
}

variable "tag_environment" {
  description = "Environment tag"
  default     = "Prod"
}

variable "tags_shared" {
  description = "Other tags assigned to all resources"
  type        = "map"

  default = {
    Owner        = "T.Durden"
    BusinessUnit = "Paper Street Soap Co."
    Department   = "Mischief"
    CostCenter   = "7741"
    Project      = "Mayhem"
  }
}
