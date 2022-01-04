data "aws_ami" "amazon-linux2" {
    most_recent = true

    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-*"]
    }

    filter {
        name = "architecture"
        values = ["x86_64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

resource "aws_security_group" "ec2" {
    name = "vote-processor-sg"
    vpc_id = aws_vpc.main.id

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    egress {
        from_port = 0
        to_port = 0
        protocol = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
}

resource "aws_instance" "vote" {
    ami = data.aws_ami.amazon-linux2.id
    instance_type = "t2.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    user_data = file("vote-processor/user-data.sh")
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.ec2.id]
    
    tags = {
        Name = "vote-processor"
    }
}
