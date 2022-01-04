resource "aws_iam_policy" "logging" {
    name = "logging"
    path = "/"
    description = "IAM policy for logging"
    policy = file("policies/logging.json")
}

resource "aws_iam_policy" "sns_publishing" {
    name = "sns_publishing"
    path = "/"
    description = "IAM policy for publishing to SNS"
    policy = file("policies/sns-publish.json")
}

resource "aws_iam_policy" "dynamodb_reading" {
    name = "dynamodb_reading"
    path = "/"
    description = "IAM policy for reading DynamoDB"
    policy = file("policies/dynamodb-read.json")
}

resource "aws_iam_policy" "dynamodb_writing" {
    name = "dynamodb_writing"
    path = "/"
    description = "IAM policy for writing to DynamoDB"
    policy = file("policies/dynamodb-write.json")
}

resource "aws_iam_policy" "sqs_reading" {
    name = "sqs_reading"
    path = "/"
    description = "IAM policy for reading from SQS"
    policy = file("policies/sqs-read.json")
}

// Lambda role
resource "aws_iam_role" "lambda" {
    name = "iam-lambda"
    description = "IAM role for lambda functions"
    assume_role_policy = file("policies/lambda-role.json")
}

resource "aws_iam_role_policy_attachment" "_lamdba_role_logging" {
    role = aws_iam_role.lambda.name
    policy_arn = aws_iam_policy.logging.arn
}

resource "aws_iam_role_policy_attachment" "_lamdba_role_sns_piblishing" {
    role = aws_iam_role.lambda.name
    policy_arn = aws_iam_policy.sns_publishing.arn
}

resource "aws_iam_role_policy_attachment" "_lamdba_role_dynamodb_reading" {
    role = aws_iam_role.lambda.name
    policy_arn = aws_iam_policy.dynamodb_reading.arn
}

//EC2 Role
resource "aws_iam_role" "ec2" {
    name = "iam-ec2"
    description = "IAM role for EC2 instances"
    assume_role_policy = file("policies/ec2-role.json")
}

resource "aws_iam_role_policy_attachment" "_ec2_role_dynamodb_writing" {
    role = aws_iam_role.ec2.name
    policy_arn = aws_iam_policy.dynamodb_writing.arn
}

resource "aws_iam_role_policy_attachment" "_ec2_role_sqs_reading" {
    role = aws_iam_role.ec2.name
    policy_arn = aws_iam_policy.sqs_reading.arn
}

resource "aws_iam_instance_profile" "ec2_profile" {
  name = "ec2_profile"
  role = aws_iam_role.ec2.name
}

// API Gateway role
resource "aws_iam_role" "api_gateway" {
  name = "aim-api-gateway"

  assume_role_policy = file("policies/api-gateway-role.json")
}

resource "aws_iam_role_policy_attachment" "_api_gateway_role_logging" {
    role = aws_iam_role.api_gateway.name
    policy_arn = aws_iam_policy.logging.arn
}
