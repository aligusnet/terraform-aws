terraform {
    required_providers {
        aws = {
            source  = "hashicorp/aws"
            version = "~> 3.27"
        }
    }

    required_version = ">= 1.1.2"
}

provider "aws" {
    profile = "default"
    region  = "us-east-1"
    default_tags {
        tags = {
            Project = "terraform.aws"
        }
    }
}
