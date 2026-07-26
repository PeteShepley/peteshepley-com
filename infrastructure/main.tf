terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    github = {
      source  = "integrations/github"
      version = "~> 6.0"
    }
  }

  backend "s3" {
    bucket         = "peteshepley-ops-tofu-state"
    key            = "static-site/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "peteshepley-ops-tofu-locks"
    encrypt        = true
  }
}

provider "aws" {
  region = var.aws_region
}

# --- S3 bucket ---

resource "aws_s3_bucket" "site" {
  bucket = var.site_bucket_name
}

resource "aws_s3_bucket_versioning" "site" {
  bucket = aws_s3_bucket.site.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_server_side_encryption_configuration" "site" {
  bucket = aws_s3_bucket.site.id
  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_public_access_block" "site" {
  bucket = aws_s3_bucket.site.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

# Bucket policy is set after CloudFront exists so we can scope it to the distribution ARN.
resource "aws_s3_bucket_policy" "site" {
  bucket = aws_s3_bucket.site.id
  policy = data.aws_iam_policy_document.site_bucket.json
}

data "aws_iam_policy_document" "site_bucket" {
  statement {
    sid    = "AllowCloudFrontOAC"
    effect = "Allow"
    principals {
      type        = "Service"
      identifiers = ["cloudfront.amazonaws.com"]
    }
    actions   = ["s3:GetObject"]
    resources = ["${aws_s3_bucket.site.arn}/*"]
    condition {
      test     = "StringEquals"
      variable = "AWS:SourceArn"
      values   = [aws_cloudfront_distribution.site.arn]
    }
  }
}

# --- CloudFront ---

data "aws_cloudfront_cache_policy" "caching_optimized" {
  name = "Managed-CachingOptimized"
}

# Managed in infra/003-dns, not here — looked up by domain rather than
# passed in as a variable/remote state output, matching the pattern used for
# the GitHub OIDC provider (see docs/runbooks/static-site-deployment.md).
data "aws_acm_certificate" "site" {
  domain      = var.domain_name
  statuses    = ["ISSUED"]
  types       = ["AMAZON_ISSUED"]
  most_recent = true
}

# The S3 origin above is REST (via OAC), not S3 website-hosting, so only the
# literal root path resolves index.html automatically. This function rewrites
# extensionless request URIs (e.g. Astro's per-page /blog/my-post/ output) to
# their index.html before they reach the origin.
resource "aws_cloudfront_function" "url_rewrite" {
  name    = "${var.site_bucket_name}-url-rewrite"
  runtime = "cloudfront-js-2.0"
  comment = "Rewrite extensionless URIs to their index.html"
  publish = true
  code    = file("${path.module}/cloudfront-functions/url-rewrite.js")
}

resource "aws_cloudfront_origin_access_control" "site" {
  name                              = "${var.site_bucket_name}-oac"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

# /api-docs/* (the published OpenAPI specs + rendered Redoc HTML) is fetched
# cross-origin by api-console (test.peteshepley.com) via Swagger UI's `url`
# prop — a plain unauthenticated GET, no cookies/credentials involved. The
# default cache behavior sends no CORS headers at all (S3-via-OAC doesn't
# add any on its own), which the browser was blocking as a cross-origin
# fetch. This is published documentation meant to be fetched from anywhere,
# not a credentialed API, so `*` here (unlike resume-api's origin allowlist,
# which guards bearer-token-carrying requests) is the appropriate scope.
resource "aws_cloudfront_response_headers_policy" "api_docs_cors" {
  name = "${var.site_bucket_name}-api-docs-cors"

  cors_config {
    origin_override                  = true
    access_control_allow_credentials = false

    access_control_allow_origins {
      items = ["*"]
    }
    access_control_allow_headers {
      items = ["*"]
    }
    access_control_allow_methods {
      items = ["GET", "HEAD"]
    }
    access_control_max_age_sec = 600
  }
}

resource "aws_cloudfront_distribution" "site" {
  enabled             = true
  default_root_object = "index.html"
  price_class         = "PriceClass_100"
  comment             = "peteshepley.com static site"
  aliases             = [var.domain_name, "www.${var.domain_name}"]

  origin {
    domain_name              = aws_s3_bucket.site.bucket_regional_domain_name
    origin_id                = "s3-site"
    origin_access_control_id = aws_cloudfront_origin_access_control.site.id
  }

  default_cache_behavior {
    target_origin_id       = "s3-site"
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    allowed_methods        = ["GET", "HEAD"]
    cached_methods         = ["GET", "HEAD"]
    cache_policy_id        = data.aws_cloudfront_cache_policy.caching_optimized.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  ordered_cache_behavior {
    path_pattern               = "/api-docs/*"
    target_origin_id           = "s3-site"
    viewer_protocol_policy     = "redirect-to-https"
    compress                   = true
    allowed_methods            = ["GET", "HEAD"]
    cached_methods             = ["GET", "HEAD"]
    cache_policy_id            = data.aws_cloudfront_cache_policy.caching_optimized.id
    response_headers_policy_id = aws_cloudfront_response_headers_policy.api_docs_cors.id

    function_association {
      event_type   = "viewer-request"
      function_arn = aws_cloudfront_function.url_rewrite.arn
    }
  }

  custom_error_response {
    error_code         = 403
    response_code      = 404
    response_page_path = "/404.html"
  }

  custom_error_response {
    error_code         = 404
    response_code      = 404
    response_page_path = "/404.html"
  }

  restrictions {
    geo_restriction {
      restriction_type = "none"
    }
  }

  viewer_certificate {
    acm_certificate_arn      = data.aws_acm_certificate.site.arn
    ssl_support_method       = "sni-only"
    minimum_protocol_version = "TLSv1.2_2021"
  }
}
