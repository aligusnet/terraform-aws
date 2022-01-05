resource "aws_cloudfront_distribution" "s3_vote" {
    origin {
        domain_name = aws_s3_bucket.bucket_vote.bucket_regional_domain_name
        origin_id = aws_s3_bucket.bucket_vote.bucket_regional_domain_name
    }

    default_cache_behavior {
        allowed_methods = ["GET", "HEAD"]
        cached_methods = ["GET", "HEAD"]
        target_origin_id = aws_s3_bucket.bucket_vote.bucket_regional_domain_name

        forwarded_values {
            query_string = false

            cookies {
                forward = "none"
            }
        }

        viewer_protocol_policy = "redirect-to-https"
        min_ttl = 0
        default_ttl = 3600
        max_ttl = 86400
        compress = true
    }

    enabled = true
    price_class = "PriceClass_100"
    default_root_object = "index.html"
    comment = "vote"
    retain_on_delete = false

    viewer_certificate {
        cloudfront_default_certificate = true
    }

    restrictions {
        geo_restriction {
            restriction_type = "none"
        }
    }
}

output "vote-url" {
    value = "https://${aws_cloudfront_distribution.s3_vote.domain_name}"
}

