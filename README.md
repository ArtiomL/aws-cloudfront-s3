# <img align="center" src="img/cf.svg">&nbsp;&nbsp; aws-cloudfront-s3&nbsp;&nbsp;<img align="center" src="img/s3.svg">
[![Releases](https://img.shields.io/github/release/ArtiomL/aws-cloudfront-s3.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/releases)
[![Commits](https://img.shields.io/github/commits-since/ArtiomL/aws-cloudfront-s3/latest.svg?label=commits%20since)](https://github.com/ArtiomL/aws-cloudfront-s3/commits/master)
[![Maintenance](https://img.shields.io/maintenance/yes/2019.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/graphs/code-frequency)
[![Issues](https://img.shields.io/github/issues/ArtiomL/aws-cloudfront-s3.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/issues)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

&nbsp;&nbsp;

## Table of Contents
- [Description](#description)
- [Input Variables](#input-variables)
- [Output Values](#output-values)
- [Example](#example)
- [License](LICENSE)

&nbsp;&nbsp;

## Description

Terraform module to provision AWS CloudFront CDN and securely serve HTTPS requests to a static website hosted on Amazon S3. The module creates:

1. S3 bucket to host static website content
2. S3 bucket to store CloudFront access log files in
3. Block Public Access settings for both S3 buckets (all four settings set to `true`)
4. CloudFront origin access identity
5. S3 bucket policy to ensure CloudFront OAI has permissions to read files in the S3 bucket, but users don't


&nbsp;&nbsp;

## Input Variables

| Name | Description | Type | Default | Required |
|------|-------------|:----:|:-----:|:-----:|
| allowed\_methods | Controls which HTTP methods CloudFront processes and forwards to your S3 bucket | list | `<list>` | no |
| aws\_region | AWS region | string | `"eu-west-1"` | no |
| cached\_methods | Controls whether CloudFront caches responses to requests using the specified HTTP methods | list | `<list>` | no |
| comment | Distribution comments | string | `"Managed by Terraform"` | no |
| compress | Compress content for web requests that include Accept-Encoding: gzip in the request header | string | `"true"` | no |
| default\_root\_object | An object CloudFront returns when the end user requests the root URL | string | `"index.html"` | no |
| default\_ttl | Default amount of time (in seconds) an object is in a CloudFront cache | string | `"3600"` | no |
| domain\_name | DNS domain name | string | n/a | yes |
| enabled | Whether the distribution is enabled to accept end user requests for content | string | `"true"` | no |
| event\_type | The specific event to trigger the function | string | `"origin-response"` | no |
| force\_destroy | All objects should be deleted from the bucket so that the bucket can be destroyed without error | string | `"true"` | no |
| geo\_restriction\_locations | ISO 3166-1-alpha-2 country codes | list | `<list>` | no |
| geo\_restriction\_type | The method to restrict distribution of your content by country (none, whitelist, blacklist) | string | `"none"` | no |
| handler | The function entrypoint in your code | string | `"index.handler"` | no |
| include\_body | Expose the request body to the Lambda function | string | `"false"` | no |
| is\_ipv6\_enabled | Whether IPv6 is enabled for the distribution | string | `"true"` | no |
| log\_days | The number of days to keep the log files | string | `"7"` | no |
| max\_ttl | Maximum amount of time an object is in a CloudFront cache | string | `"86400"` | no |
| min\_ttl | Minimum amount of time you want objects to stay in CloudFront caches | string | `"0"` | no |
| minimum\_protocol\_version | The minimum TLS version that you want CloudFront to use for HTTPS connections | string | `"TLSv1_2016"` | no |
| origin\_path | Causes CloudFront to request content from a directory in your S3 bucket | string | `""` | no |
| price\_class | The price class for this distribution (PriceClass_All, PriceClass_200, PriceClass_100) | string | `"PriceClass_All"` | no |
| runtime | Function runtime identifier | string | `"nodejs8.10"` | no |
| source\_file | Package this file into the function archive (index.js local to the module path is used by default) | string | `""` | no |
| tag\_environment | Environment tag | string | `"Prod"` | no |
| tag\_name | Name tag | string | `"AWSLabs"` | no |
| tags\_shared | Other tags assigned to all resources | map | `<map>` | no |
| viewer\_protocol\_policy | The protocol users can use to access the origin files (allow-all, https-only, redirect-to-https) | string | `"redirect-to-https"` | no |
| wait\_for\_deployment | Wait for the distribution status to change from InProgress to Deployed | string | `"false"` | no |
| zone\_id | Route 53 zone ID | string | n/a | yes |

&nbsp;&nbsp;

## Output Values

| Name | Description |
|------|-------------|
| bucket\_id | S3 bucket name |
| bucket\_regional | S3 bucket region-specific domain name, also used as CloudFront Origin ID |
| cert\_arn | ACM certificate ARN |
| dist\_arn | CloudFront distribution ARN |
| dist\_domain | CloudFront distribution domain name |
| dist\_id | CloudFront distribution ID |
| dist\_zone\_id | CloudFront zone ID that can be used to point Route 53 alias records to |

&nbsp;&nbsp;

## Example

```hcl
# S3, IAM, ACM, CloudFront
module "aws_cloudfront_s3" {
  source          = "github.com/ArtiomL/aws-cloudfront-s3"
  aws_region      = "us-east-1"
  domain_name     = "artl.dev"
  source_file     = "index.js"
  zone_id         = "${aws_route53_zone.main.zone_id}"
  tag_name        = "AWSLabs"
  tag_environment = "Dev"
}
```
