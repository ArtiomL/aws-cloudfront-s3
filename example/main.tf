# Infrastructure

# S3, IAM, ACM, CloudFront
module "aws_cloudfront_s3" {
  source          = "github.com/ArtiomL/aws-cloudfront-s3"
  aws_region      = "eu-west-1"
  domain_name     = "example.com"
  zone_id         = "Z3P5QSUBK4POTI"
  tag_name        = "Example"
  tag_environment = "Dev"
}

# Upload local files to S3
resource "null_resource" "main" {
  provisioner "local-exec" {
    command = "aws s3 sync docs/ s3://${module.aws_cloudfront_s3.bucket_id}"
  }
}

# Slack notification
module "slack" {
  source       = "github.com/ArtiomL/aws-terraform/modules/common/slack"
  message_text = "Deployed: ${module.aws_cloudfront_s3.bucket_id} as ${module.aws_cloudfront_s3.dist_domain}"
  webhook_url  = "T00000000/B00000000/XXXXXXXXXXXXXXXXXXXXXXXX"
}
