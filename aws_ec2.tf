data "aws_ami" "amazon-linux2" {
    most_recent = true

    owners = ["amazon"]

    filter {
        name = "name"
        values = ["amzn2-ami-*"]
    }

    filter {
        name = "architecture"
        values = ["arm64"]
    }

    filter {
        name = "virtualization-type"
        values = ["hvm"]
    }
}

locals {
  cloud_config_config = <<-END
    #cloud-config
    ${jsonencode({
      write_files = [
        {
          path        = "/bin/processor.py"
          permissions = "0755"
          owner       = "root:root"
          encoding    = "b64"
          content     = base64encode(data.template_file.processor_py.rendered)
        },
      ]
    })}
  END
}

data "template_file" "processor_py" {
    template = file("${path.module}/vote-processor/processor.py")
    vars = {
        region = var.region
    }
}

data "cloudinit_config" "ec2" {
  gzip          = false
  base64_encode = false

  part {
    content_type = "text/cloud-config"
    filename     = "cloud-config.yaml"
    content      = local.cloud_config_config
  }

  part {
    content_type = "text/x-shellscript"
    filename     = "user-data.sh"
    content  = file("vote-processor/user-data.sh")
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

resource "aws_key_pair" "terraform" {
  key_name   = "Terraform"
  public_key = file("~/.ssh/aws_terraform.pub")
}

resource "aws_instance" "vote" {
    ami = data.aws_ami.amazon-linux2.id
    instance_type = "t4g.micro"
    iam_instance_profile = aws_iam_instance_profile.ec2_profile.name
    user_data = data.cloudinit_config.ec2.rendered
    subnet_id = aws_subnet.public.id
    vpc_security_group_ids = [aws_security_group.ec2.id]
    key_name = aws_key_pair.terraform.key_name
    
    tags = {
        Name = "vote-processor"
    }
}
