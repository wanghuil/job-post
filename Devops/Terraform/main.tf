data "template_file" "bucket_policy" {
  template = file("./website_bucket_policy.json")

  vars = {
    bucket = var.bucket_name
  }
}

#s3
resource "aws_s3_bucket" "prod_media" {
  bucket   = var.bucket_name
  provider = aws.ap_southeast_2

  website {
    index_document = "register.html"
    error_document = "404.html"
  }
}

resource "aws_s3_bucket_public_access_block" "example" {
  bucket = aws_s3_bucket.prod_media.id

  block_public_acls       = false
  block_public_policy     = false
  ignore_public_acls      = false
  restrict_public_buckets = false

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_acl" "prod_media" {
  bucket = aws_s3_bucket.prod_media.id
  acl    = "public-read-write"

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_ownership_controls" "s3_bucket_acl_ownership" {
  bucket = aws_s3_bucket.prod_media.id
  rule {
    object_ownership = "BucketOwnerPreferred"
  }

  depends_on = [aws_s3_bucket.prod_media]
}

resource "aws_s3_bucket_policy" "prod_media_bucket" {
  bucket = aws_s3_bucket.prod_media.id
  policy = data.template_file.bucket_policy.rendered

  depends_on = [aws_s3_bucket.prod_media]
}

#acm
# Provider configuration for us-east-1 region (alias: us_east_1)
provider "aws" {
  region = "us-east-1"
  alias  = "us_east_1"
}

resource "aws_acm_certificate" "my_certificate" {
  domain_name               = "land-tasker.link"
  subject_alternative_names = ["*.land-tasker.link"]
  validation_method         = "DNS"
  provider                  = aws.us_east_1
}

#add cname to r53
locals {
  domain_validation_options_list = tolist(aws_acm_certificate.my_certificate.domain_validation_options)
}

resource "aws_route53_record" "cname_record" {
  zone_id = var.r53_zone_id
  name    = local.domain_validation_options_list[0].resource_record_name
  type    = "CNAME"
  ttl     = 300
  records = [local.domain_validation_options_list[0].resource_record_value]
}

# Explicit dependency on the ACM certificate validation
resource "aws_acm_certificate_validation" "cert_validation" {
  provider                = aws.us_east_1
  certificate_arn         = aws_acm_certificate.my_certificate.arn
  validation_record_fqdns = [aws_route53_record.cname_record.fqdn]

  depends_on = [aws_acm_certificate.my_certificate]
}


#add oai to cfn
# resource "aws_cloudfront_origin_access_identity" "oai" {
#   comment = "land-tasker-oai"
# }

#add oac to cfn
resource "aws_cloudfront_origin_access_control" "oac" {
  name                              = "land-tasker-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"

}

# Output the OAI ID
# output "oai_id" {
#   value = aws_cloudfront_origin_access_identity.oai.id
# }

#cfn
resource "aws_cloudfront_distribution" "website_cdn" {
  enabled         = true
  is_ipv6_enabled = var.ipv6
  price_class     = var.price_class
  http_version    = "http2"

  origin {
    origin_id                = "origin-bucket-${aws_s3_bucket.prod_media.id}"
    domain_name              = aws_s3_bucket.prod_media.bucket_domain_name
    origin_access_control_id = aws_cloudfront_origin_access_control.oac.id

    # s3_origin_config {
    #   origin_access_identity = aws_cloudfront_origin_access_control.oac.cloudfront_access_identity_path
    # }

    # custom_origin_config {
    #   origin_protocol_policy = "http-only"
    #   http_port              = "80"
    #   https_port             = "443"
    #   origin_ssl_protocols   = ["TLSv1"]
    # }

    custom_header {
      name  = "User-Agent"
      value = var.duplicate-content-penalty-secret
    }

  }

  default_root_object = var.default-root-object

  custom_error_response {
    error_code            = "404"
    error_caching_min_ttl = "360"
    response_code         = var.not-found-response-code
    response_page_path    = var.not-found-response-path
  }

  default_cache_behavior {
    allowed_methods = ["GET", "HEAD", "DELETE", "OPTIONS", "PATCH", "POST", "PUT"]
    cached_methods  = ["GET", "HEAD"]

    forwarded_values {
      query_string = var.forward-query-string

      cookies {
        forward = "none"
      }

    }

    trusted_signers = var.trusted_signers

    min_ttl          = "0"
    default_ttl      = "300"  //3600
    max_ttl          = "1200" //86400
    target_origin_id = "origin-bucket-${aws_s3_bucket.prod_media.id}"

    // This redirects any HTTP request to HTTPS. Security first!
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = aws_acm_certificate.my_certificate.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = var.minimum_client_tls_protocol_version
  }

  aliases = ["www.land-tasker.link"]
}

# Export the CloudFront distribution ARN
output "cloudfront_distribution_arn" {
  value = aws_cloudfront_distribution.website_cdn.arn
}

# Add cloudfront bucket policy to s3
data "template_file" "cloudfront_bucket_policy" {
  template = file("./cloudfront_bucket_policy.json")

  vars = {
    bucket = var.bucket_name
    #oai_id = aws_cloudfront_origin_access_identity.oai.id
    cloudfront_distribution_arn = aws_cloudfront_distribution.website_cdn.arn
  }
}

resource "aws_s3_bucket_policy" "cloudfront_prod_media_bucket" {
  bucket = aws_s3_bucket.prod_media.id
  policy = data.template_file.cloudfront_bucket_policy.rendered

  depends_on = [aws_cloudfront_distribution.website_cdn, aws_s3_bucket.prod_media]
}

#add cloudfront a record to r53
resource "aws_route53_record" "cloudfront_bucket_record" {
  zone_id = var.r53_zone_id
  name    = "www.land-tasker.link"
  type    = "A"

  alias {
    name                   = aws_cloudfront_distribution.website_cdn.domain_name
    zone_id                = aws_cloudfront_distribution.website_cdn.hosted_zone_id
    evaluate_target_health = true
  }
}

#Block s3 Public Access 
# resource "aws_s3_account_public_access_block" "bucket_public_access_block" {
#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true

#   depends_on = [aws_s3_bucket_policy.cloudfront_prod_media_bucket]
# }







