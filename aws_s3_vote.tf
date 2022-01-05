locals {
    bucket_vote = "voting-frontend-${var.s3_bucket_suffix}"
}

resource "aws_s3_bucket" "bucket_vote" {
    bucket = local.bucket_vote
    acl = "public-read"
    policy = "${data.template_file.s3_public_policy.rendered}"

    website {
        index_document = "index.html"
    }
}

data "template_file" "s3_public_policy" {
    template = "${file("${path.module}/policies/s3-public.json")}"
    vars = {
        bucket_name = local.bucket_vote
    }
}

resource "aws_s3_bucket_object" "_vote_index_file" {
    bucket = aws_s3_bucket.bucket_vote.id
    key = "index.html"
    content = templatefile("voting-frontend/index.html", {backend-url = "${aws_apigatewayv2_stage.default.invoke_url}vote"})
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "_vote_css_file" {
    bucket = aws_s3_bucket.bucket_vote.id
    source = "voting-frontend/style.css"
    key = "style.css"
    content_type = "text/css"
}

output "voting-url" {
    value = aws_s3_bucket.bucket_vote.website_endpoint
}
