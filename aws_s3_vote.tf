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

data "template_file" "vote_index_file" {
    template = "${file("${path.module}/voting-frontend/index.html")}"
    vars = {
        backend-url = "${aws_apigatewayv2_stage.default.invoke_url}vote"
    }
}

resource "aws_s3_bucket_object" "_vote_index_file" {
    bucket = aws_s3_bucket.bucket_vote.id
    key = "index.html"
    content = data.template_file.vote_index_file.rendered
    source_hash = md5(data.template_file.vote_index_file.rendered)
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "_vote_css_file" {
    bucket = aws_s3_bucket.bucket_vote.id
    source = "voting-frontend/style.css"
    source_hash = filemd5("voting-frontend/style.css")
    key = "style.css"
    content_type = "text/css"
}

