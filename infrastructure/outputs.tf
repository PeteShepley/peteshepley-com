output "site_bucket_name" {
  description = "Name of the site S3 bucket"
  value       = aws_s3_bucket.site.id
}

output "site_bucket_arn" {
  description = "ARN of the site S3 bucket"
  value       = aws_s3_bucket.site.arn
}

output "cloudfront_distribution_id" {
  description = "ID of the CloudFront distribution — needed for cache invalidations"
  value       = aws_cloudfront_distribution.site.id
}

output "cloudfront_distribution_arn" {
  description = "ARN of the CloudFront distribution"
  value       = aws_cloudfront_distribution.site.arn
}

output "cloudfront_domain_name" {
  description = "Default CloudFront domain — use this to test the site before the custom domain is configured"
  value       = aws_cloudfront_distribution.site.domain_name
}

output "github_deploy_role_arn" {
  description = "ARN for the GitHub Actions deploy role — set this as AWS_ROLE_ARN in the repo's Actions secrets"
  value       = aws_iam_role.github_deploy.arn
}
