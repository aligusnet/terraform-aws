locals {
    bucket_result = "result-frontend-${var.s3_bucket_suffix}"
}

resource "aws_s3_bucket" "bucket_result" {
    bucket = local.bucket_result
    acl = "public-read"
    policy = data.template_file.s3_public_policy_result.rendered

    website {
        index_document = "index.html"
    }
}

data "template_file" "s3_public_policy_result" {
    template = file("${path.module}/policies/s3-public.json")
    vars = {
        bucket_name = local.bucket_result
    }
}

data "template_file" "result_js_file" {
    template = file("${path.module}/result-frontend/app.js")
    vars = {
        backend-url = "${aws_apigatewayv2_stage.default.invoke_url}result"
    }
}

resource "aws_s3_bucket_object" "_result_index_file" {
    bucket = aws_s3_bucket.bucket_result.id
    key = "index.html"
    source = "result-frontend/index.html"
    source_hash = filemd5("result-frontend/index.html")
    content_type = "text/html"
}

resource "aws_s3_bucket_object" "_result_css_file" {
    bucket = aws_s3_bucket.bucket_result.id
    source = "result-frontend/style.css"
    source_hash = filemd5("result-frontend/style.css")
    key = "style.css"
    content_type = "text/css"
}

resource "aws_s3_bucket_object" "_result_js_file" {
    bucket = aws_s3_bucket.bucket_result.id
    key = "app.js"
    content = data.template_file.result_js_file.rendered
    source_hash = md5(data.template_file.result_js_file.rendered)
    content_type = "application/javascript"
}
