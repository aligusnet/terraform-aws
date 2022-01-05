locals {
   result_lambda_function_name = "lambda_vote_result"
}

resource "aws_cloudwatch_log_group" "result_lambda" {
    name = "/aws/lambda/${local.result_lambda_function_name}"
    retention_in_days = 3
}

data "archive_file" "lambda_result" {
    type = "zip"
    source_file = "${path.module}/lambda/result.py"
    output_path = "${path.module}/files/result-lambda.zip"
}

resource "aws_lambda_function" "result" {
    filename = data.archive_file.lambda_result.output_path
    function_name = local.result_lambda_function_name
    role = aws_iam_role.lambda.arn
    handler = "result.lambda_handler"

    source_code_hash = filebase64sha256(data.archive_file.lambda_result.output_path)

    runtime = "python3.9"
    architectures = ["arm64"]

    environment {
        variables = {
            TOPIC_ARN = aws_sns_topic.votes_topic.arn
        }
    }

    depends_on = [
        aws_cloudwatch_log_group.result_lambda,
    ]
}
