output "site_bucket_name" {
  description = "Name of the site S3 bucket"
  value       = module.app.site_bucket_name
}

output "site_bucket_arn" {
  description = "ARN of the site S3 bucket"
  value       = module.app.site_bucket_arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution — needed for cache invalidations"
  value       = module.app.cloudfront_distribution_id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = module.app.cloudfront_distribution_arn
}

output "cloudfront_domain_name" {
  description = "Default CloudFront domain — use this to test the site before the custom domain is configured"
  value       = module.app.cloudfront_domain_name
}

output "cloudfront_hosted_zone_id" {
  description = "CloudFront's hosted zone ID — needed for the Route53 alias record in infra/003-root-dns"
  value       = module.app.cloudfront_hosted_zone_id
}

output "github_deploy_role_arn" {
  description = "ARN for the GitHub Actions deploy role — set this as AWS_ROLE_ARN in the repo's Actions secrets"
  sensitive   = true
  value       = data.aws_ssm_parameter.deploy_role_arn.value
}
