locals {
    api_gateway_name = "vote-api"
}

resource "aws_apigatewayv2_api" "vote" {
    name = local.api_gateway_name
    protocol_type = "HTTP"

    tags = {
        Name = "vote-api"
    }

    cors_configuration {
        allow_origins = [
            "http://${aws_s3_bucket.bucket_vote.website_endpoint}",
            "http://${aws_s3_bucket.bucket_result.website_endpoint}",
            "https://${aws_cloudfront_distribution.s3_vote.domain_name}",
            "https://${aws_cloudfront_distribution.s3_result.domain_name}",
            ]
        expose_headers = ["*"]
        max_age = 3000
        allow_methods = ["*"]
        allow_headers = ["*"]
    }
}

resource "aws_lambda_permission" "vote" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.vote.arn
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.vote.execution_arn}/*/*"
}

resource "aws_lambda_permission" "result" {
    action        = "lambda:InvokeFunction"
    function_name = aws_lambda_function.result.arn
    principal     = "apigateway.amazonaws.com"

    source_arn = "${aws_apigatewayv2_api.vote.execution_arn}/*/*"
}

resource "aws_apigatewayv2_stage" "default" {
    api_id = aws_apigatewayv2_api.vote.id
    name = "$default"
    auto_deploy = "true"

    access_log_settings {
        destination_arn = aws_cloudwatch_log_group.api_gateway.arn
        format = "$context.identity.sourceIp - - [$context.requestTime] \"$context.httpMethod $context.routeKey $context.protocol\" $context.status $context.responseLength $context.requestId"
    }
}

resource "aws_apigatewayv2_route" "vote" {
    api_id    = aws_apigatewayv2_api.vote.id
    route_key = "POST /vote"
    target = "integrations/${aws_apigatewayv2_integration.vote-lambda.id}"
}

resource "aws_apigatewayv2_route" "result" {
    api_id    = aws_apigatewayv2_api.vote.id
    route_key = "GET /result"
    target = "integrations/${aws_apigatewayv2_integration.result-lambda.id}"
}

resource "aws_apigatewayv2_integration" "vote-lambda" {
    api_id = aws_apigatewayv2_api.vote.id
    integration_type = "AWS_PROXY"

    integration_method = "POST"
    integration_uri = aws_lambda_function.vote.invoke_arn
}

resource "aws_apigatewayv2_integration" "result-lambda" {
    api_id = aws_apigatewayv2_api.vote.id
    integration_type = "AWS_PROXY"

    integration_method = "POST"
    integration_uri = aws_lambda_function.result.invoke_arn
}

resource "aws_cloudwatch_log_group" "api_gateway" {
    name = "/aws/api_gateway/${local.api_gateway_name}"
    retention_in_days = 3
}
