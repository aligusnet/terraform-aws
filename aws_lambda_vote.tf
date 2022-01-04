variable "voting_lambda_function_name" {
  default = "lambda_voting"
}

resource "aws_cloudwatch_log_group" "voting_lambda" {
    name = "/aws/lambda/${var.voting_lambda_function_name}"
    retention_in_days = 3
}

data "archive_file" "lambda_vote" {
    type = "zip"
    source_file = "${path.module}/lambda/voting.py"
    output_path = "${path.module}/files/voting-lambda.zip"
}

resource "aws_lambda_function" "vote" {
    filename = data.archive_file.lambda_vote.output_path
    function_name = var.voting_lambda_function_name
    role = aws_iam_role.lambda.arn
    handler = "voting.lambda_handler"

    source_code_hash = filebase64sha256(data.archive_file.lambda_vote.output_path)

    runtime = "python3.9"

    environment {
        variables = {
            TOPIC_ARN = aws_sns_topic.votes_topic.arn
        }
    }

    depends_on = [
        aws_cloudwatch_log_group.voting_lambda,
    ]
}
