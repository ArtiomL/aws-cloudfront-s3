# <img align="center" src="img/cf.svg">&nbsp;&nbsp; aws-cloudfront-s3&nbsp;&nbsp;<img align="center" src="img/s3.svg">
[![Releases](https://img.shields.io/github/release/ArtiomL/aws-cloudfront-s3.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/releases)
[![Commits](https://img.shields.io/github/commits-since/ArtiomL/aws-cloudfront-s3/latest.svg?label=commits%20since)](https://github.com/ArtiomL/aws-cloudfront-s3/commits/master)
[![Maintenance](https://img.shields.io/maintenance/yes/2019.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/graphs/code-frequency)
[![Issues](https://img.shields.io/github/issues/ArtiomL/aws-cloudfront-s3.svg)](https://github.com/ArtiomL/aws-cloudfront-s3/issues)
[![License](https://img.shields.io/badge/license-MIT-blue.svg)](/LICENSE)

&nbsp;&nbsp;

## Table of Contents
- [Description](#description)
	- [Architecture](#architecture)
	- [Security](#security)
- [Input Variables](#input-variables)
- [Output Values](#output-values)
- [Example](#example)
- [License](LICENSE)

&nbsp;&nbsp;

## Description

Terraform AWS module to provision CloudFront CDN and securely serve HTTPS requests to a static website hosted on Amazon S3. 

### Architecture

<p align="center"><img src="img/arc.png"></p>

The module creates:

- [S3 bucket](https://docs.aws.amazon.com/AmazonS3/latest/dev/UsingBucket.html) to host static website content
- S3 bucket to store CloudFront [access log](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/AccessLogs.html) files in
- [Block Public Access](https://docs.aws.amazon.com/AmazonS3/latest/dev/access-control-block-public-access.html) settings for both S3 buckets (all four settings set to `true`)
- CloudFront [origin access identity](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/private-content-restricting-access-to-s3.html)
- S3 bucket policy to ensure CloudFront OAI has permissions to read files in the S3 bucket, but users don't
- ACM public SSL/TLS certificate for your domain, using [DNS validation](https://docs.aws.amazon.com/acm/latest/userguide/gs-acm-validate-dns.html)
- Route 53 CNAME record for ACM validation
- CloudFront [distribution](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/distribution-working-with.html) with IPv6, TLS, SNI and [HTTP/2](https://css-tricks.com/http2-real-world-performance-test-analysis/) support targeting an S3 origin
- Lambda@Edge [function](index.js) to [customize](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-at-the-edge.html) the content CloudFront delivers
- Route 53 A and AAAA alias records to the CloudFront distribution

### Security

The default Lambda@Edge [function](index.js) is used to add the following [HTTP security](https://aws.amazon.com/blogs/networking-and-content-delivery/adding-http-security-headers-using-lambdaedge-and-amazon-cloudfront/) response headers, triggered by the [Origin Response](https://docs.aws.amazon.com/AmazonCloudFront/latest/DeveloperGuide/lambda-cloudfront-trigger-events.html) CloudFront event:

```http
Strict-Transport-Security: max-age=63072000; includeSubDomains; preload
X-XSS-Protection: 1; mode=block
X-Content-Type-Options: nosniff
X-Frame-Options: DENY
Referrer-Policy: no-referrer
Content-Security-Policy: default-src 'self'; script-src 'self'; style-src 'self'; img-src 'self'; font-src 'self';
Feature-Policy: geolocation 'none'; midi 'none'; sync-xhr 'none'; microphone 'none'; camera 'none'; magnetometer 'none'; gyroscope 'none'; speaker 'self'; vibrate 'none'; fullscreen 'self'; payment 'none';
```

Scanning the website with [HTTP Observatory](https://observatory.mozilla.org/) results in:

<p align="center"><img src="img/ap.png" width="500"></p>

Use the module input variables to specify a filename with custom function code (`source_file`) and the CloudFront event to trigger it (`event_type`).

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
| minimum\_protocol\_version | The minimum TLS version that you want CloudFront to use for HTTPS connections | string | `"TLSv1.2_2018"` | no |
| origin\_path | Causes CloudFront to request content from a directory in your S3 bucket | string | `""` | no |
| price\_class | The price class for this distribution (PriceClass_All, PriceClass_200, PriceClass_100) | string | `"PriceClass_All"` | no |
| runtime | Function runtime identifier | string | `"nodejs10.x"` | no |
| source\_file | Package this file into the function archive (index.js local to the module path is used by default) | string | `""` | no |
| tag\_environment | Environment tag | string | `"Prod"` | no |
| tag\_name | Name tag | string | `"AWSLabs"` | no |
| tags\_shared | Other tags assigned to all resources | map | `<map>` | no |
| viewer\_protocol\_policy | The protocol users can use to access the origin files (allow-all, https-only, redirect-to-https) | string | `"redirect-to-https"` | no |
| wait\_for\_deployment | Wait for the distribution status to change from InProgress to Deployed | string | `"false"` | no |
| web\_acl\_id | AWS WAF Web ACL ID | string | `""` | no |
| zone\_id | Route 53 zone ID | string | n/a | yes |

&nbsp;&nbsp;

## Output Values

| Name | Description |
|------|-------------|
| alias\_fqdn | DNS alias record FQDN |
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
  aws_region      = "eu-north-1"
  domain_name     = "artl.dev"
  source_file     = "custom.js"
  zone_id         = aws_route53_zone.main.zone_id
  tag_name        = "AWSLabs"
  tag_environment = "Dev"
}
```
