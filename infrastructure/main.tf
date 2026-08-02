terraform {
  required_version = ">= 1.6.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
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

# The consolidated per-repo GitHub OIDC deploy role (gha-deploy-peteshepley-com),
# created in operations/infra/002-github-projects. Passed into the module below
# as deploy_role_name so its own deploy policy attaches there instead of
# creating its own role.
data "aws_ssm_parameter" "deploy_role_name" {
  name = "/github-deploy/peteshepley-com/role-name"
}

data "aws_ssm_parameter" "deploy_role_arn" {
  name = "/github-deploy/peteshepley-com/role-arn"
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

# --- Static app (S3 + CloudFront + GitHub OIDC deploy role) ---
# peteshepley.com is an Astro multi-page site, not a Vite SPA, so it uses
# the module's non-default options: a viewer-request rewrite function
# (Astro's extensionless per-page URIs -> their index.html), a real 404
# page instead of an SPA fallback, the apex + www aliases, and an extra
# cache behavior for /api-docs/*'s CORS policy above. See
# github.com/PeteShepley/terraform-aws-static-app for what's common and
# why, and its README for what each of these variables does.
module "app" {
  source = "github.com/PeteShepley/terraform-aws-static-app"

  # app_name now only names the inline policy attached to the externally
  # created role below (create_deploy_role = false) — changing it renames
  # that policy, not the role, so it's no longer the force-replace hazard
  # the previous version of this comment warned about.
  app_name             = "static-site"
  site_bucket_name     = var.site_bucket_name
  domain_name          = var.domain_name
  root_domain_name     = var.root_domain_name
  distribution_comment = "peteshepley.com static site"
  github_repo          = var.github_repo

  create_deploy_role = false
  deploy_role_name   = data.aws_ssm_parameter.deploy_role_name.value

  extra_aliases = ["www.${var.domain_name}"]

  # Keeps the existing peteshepley-com-site-url-rewrite function name —
  # the module's own default suffix ("-viewer-request") would force a
  # destroy/recreate of this ForceNew resource for no functional reason.
  viewer_request_function_code = file("${path.module}/cloudfront-functions/url-rewrite.js")
  viewer_request_function_name = "${var.site_bucket_name}-url-rewrite"

  extra_ordered_cache_behaviors = [
    {
      path_pattern               = "/api-docs/*"
      response_headers_policy_id = aws_cloudfront_response_headers_policy.api_docs_cors.id
    }
  ]

  spa_fallback    = false
  error_page_path = "/404.html"
}
