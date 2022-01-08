resource "aws_dynamodb_table" "votes" {
    name = "Votes"
    billing_mode = "PAY_PER_REQUEST"
    hash_key = "voter"

    attribute {
        name = "voter"
        type = "S"
    }
}

resource "aws_dynamodb_table_item" "init" {
    table_name = aws_dynamodb_table.votes.name
    hash_key = aws_dynamodb_table.votes.hash_key

    item = <<ITEM
    {
        "voter": {
        "S": "count"
        },
        "a": {
            "N": "11"
        },
        "b": {
            "N": "20"
        }
    }
    ITEM
}
