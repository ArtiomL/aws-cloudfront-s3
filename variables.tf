variable "aws_region" {
  description = "AWS region"
  default     = "eu-west-1"
}

# --- DNS --- #


variable "domain_name" {
  description = "DNS domain name"
}

variable "zone_id" {
  description = "Route 53 zone ID"
}

# --- Tags --- #

variable "tag_name" {
  description = "Name tag"
  default     = "S3"
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

variable "enabled" {
  default     = "true"
  description = "Select Enabled if you want CloudFront to begin processing requests as soon as the distribution is created, or select Disabled if you do not want CloudFront to begin processing requests after the distribution is created."
}

variable "minimum_protocol_version" {
  description = "Cloudfront TLS minimum protocol version"
  default     = "TLSv1"
}

variable "origin_path" {
  description = "An optional element that causes CloudFront to request your content from a directory in your Amazon S3 bucket or your custom origin. It must begin with a /. Do not add a / at the end of the path."
  default     = ""
}

variable "origin_force_destroy" {
  default     = "true"
  description = "Delete all objects from the bucket  so that the bucket can be destroyed without error (e.g. `true` or `false`)"
}

variable "compress" {
  default     = "true"
  description = "Compress content for web requests that include Accept-Encoding: gzip in the request header"
}

variable "is_ipv6_enabled" {
  default     = "true"
  description = "State of CloudFront IPv6"
}

variable "default_root_object" {
  default     = "index.html"
  description = "Object that CloudFront return when requests the root URL"
}

variable "comment" {
  default     = "Managed by Terraform"
  description = "Comment for the origin access identity"
}

variable "price_class" {
  default     = "PriceClass_All"
  description = "Price class for this distribution: `PriceClass_All`, `PriceClass_200`, `PriceClass_100`"
}

variable "viewer_protocol_policy" {
  description = "allow-all, redirect-to-https"
  default     = "redirect-to-https"
}

variable "allowed_methods" {
  type        = "list"
  default     = ["GET", "HEAD"]
  description = "List of allowed methods (e.g. GET, PUT, POST, DELETE, HEAD) for AWS CloudFront"
}

variable "cached_methods" {
  type        = "list"
  default     = ["GET", "HEAD"]
  description = "List of cached methods (e.g. GET, PUT, POST, DELETE, HEAD)"
}

variable "default_ttl" {
  default     = "3600"
  description = "Default amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "min_ttl" {
  default     = "0"
  description = "Minimum amount of time that you want objects to stay in CloudFront caches"
}

variable "max_ttl" {
  default     = "86400"
  description = "Maximum amount of time (in seconds) that an object is in a CloudFront cache"
}

variable "geo_restriction_type" {
  # e.g. "whitelist"
  default     = "none"
  description = "Method that use to restrict distribution of your content by country: `none`, `whitelist`, or `blacklist`"
}

variable "geo_restriction_locations" {
  type = "list"

  # e.g. ["US", "CA", "GB", "DE"]
  default     = []
  description = "List of country codes for which  CloudFront either to distribute content (whitelist) or not distribute your content (blacklist)"
}

variable "wait_for_deployment" {
  type        = "string"
  default     = "false"
  description = "When set to 'true' the resource will wait for the distribution status to change from InProgress to Deployed"
}


variable "force_destroy" {
  default = "true"
  }
