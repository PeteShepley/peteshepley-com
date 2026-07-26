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
  description = "Custom domain aliased to this distribution — cert and DNS records for it are managed in infra/003-root-dns"
  type        = string
  default     = "peteshepley.com"
}

variable "root_domain_name" {
  description = "Root domain whose wildcard ACM cert (managed in operations/infra/003-root-dns) covers domain_name — same as domain_name here, since peteshepley.com is itself the apex"
  type        = string
  default     = "peteshepley.com"
}

variable "github_repo" {
  description = "GitHub repository allowed to assume the deploy role (format: owner/repo)"
  type        = string
  default     = "PeteShepley/peteshepley-com"
}
