# Output Variables

output "bucket_id" {
  description = "S3 bucket name"
  value       = "${aws_s3_bucket.main.id}"
}

output "bucket_regional" {
  description = "S3 bucket region-specific domain name, also used as CloudFront Origin ID"
  value       = "${aws_s3_bucket.main.bucket_regional_domain_name}"
}

output "cert_arn" {
  description = "ACM certificate ARN"
  value       = "${aws_acm_certificate.main.arn}"
}

output "dist_id" {
  description = "CloudFront distribution ID"
  value       = "${aws_cloudfront_distribution.main.id}"
}

output "dist_arn" {
  description = "CloudFront distribution ARN"
  value       = "${aws_cloudfront_distribution.main.arn}"
}

output "dist_domain" {
  description = "CloudFront distribution domain name"
  value       = "${aws_cloudfront_distribution.main.domain_name}"
}

output "dist_zone_id" {
  description = "CloudFront zone ID that can be used to point Route 53 alias records to"
  value       = "${aws_cloudfront_distribution.main.hosted_zone_id}"
}

output "alias_fqdn" {
  description = "DNS alias record FQDN"
  value       = "${aws_route53_record.main.fqdn}"
}
