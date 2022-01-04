variable "result_lambda_function_name" {
  default = "lambda_result"
}

resource "aws_cloudwatch_log_group" "_result-lambda" {
    name = "/aws/lambda/${var.result_lambda_function_name}"
    retention_in_days = 3
}

data "archive_file" "lambda_result" {
    type = "zip"
    source_file = "${path.module}/lambda/result.py"
    output_path = "${path.module}/files/result-lambda.zip"
}

resource "aws_lambda_function" "result" {
    filename = data.archive_file.lambda_result.output_path
    function_name = var.result_lambda_function_name
    role = aws_iam_role.lambda.arn
    handler = "result.lambda_handler"

    source_code_hash = filebase64sha256(data.archive_file.lambda_result.output_path)

    runtime = "python3.9"

    environment {
        variables = {
            TOPIC_ARN = aws_sns_topic.votes_topic.arn
        }
    }
}
