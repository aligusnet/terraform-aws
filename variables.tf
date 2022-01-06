variable "region" {
    description = "AWS region"
    default = "us-east-1"
}

variable "s3_bucket_suffix" {
    description = "Used to provide global uniqness of S3 bucket names"
    default = "some-unique-value"
}
