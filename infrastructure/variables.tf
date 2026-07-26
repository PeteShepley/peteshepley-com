variable "aws_region" {
  description = "AWS region for site resources"
  type        = string
  default     = "us-east-1"
}

variable "site_bucket_name" {
  description = "Globally unique name for the S3 bucket that stores static site content"
  type        = string
  default     = "peteshepley-com-site"
}

variable "domain_name" {
  description = "Custom domain aliased to this distribution — cert and DNS records for it are managed in infra/003-dns"
  type        = string
  default     = "peteshepley.com"
}

variable "github_owner" {
  description = "GitHub organization or user that owns the repositories managed in this stack"
  type        = string
  default     = "PeteShepley"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the deploy role (format: owner/repo)"
  type        = string
  default     = "PeteShepley/peteshepley-com"
}
