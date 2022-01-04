resource "aws_sns_topic" "votes_topic" {
    name = "votes-topic"
}

resource "aws_sqs_queue" "votes_queue" {
    name = "votes-queue"
}

resource "aws_sqs_queue_policy" "_" {
    queue_url = aws_sqs_queue.votes_queue.id

    policy = <<POLICY
    {
        "Version": "2012-10-17",
        "Id": "sqspolicy",
        "Statement": [
            {
            "Sid": "First",
            "Effect": "Allow",
            "Principal": "*",
            "Action": "sqs:SendMessage",
            "Resource": "${aws_sqs_queue.votes_queue.arn}",
            "Condition": {
                "ArnEquals": {
                "aws:SourceArn": "${aws_sns_topic.votes_topic.arn}"
                }
            }
            }
        ]
    }
    POLICY
}

resource "aws_sns_topic_subscription" "user_updates_sqs_target" {
    topic_arn = aws_sns_topic.votes_topic.arn
    protocol  = "sqs"
    endpoint  = aws_sqs_queue.votes_queue.arn
}
