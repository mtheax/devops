terraform {
  required_version = ">= 1.5"
  required_providers {
    aws = { source = "hashicorp/aws", version = "~> 5.0" }
  }

  # State у S3, щоб повторні запуски CI оновлювали наявну інфраструктуру,
  # а не створювали нову. Бакет створіть вручну один раз і замініть назву.
  backend "s3" {
    bucket = "devops-mtheax-bucket-2026"
    key    = "nodeapp/terraform.tfstate"
    region = "eu-north-1"
  }
}

provider "aws" {
  region = var.region
}

data "aws_ami" "ubuntu" {
  most_recent = true
  owners      = ["099720109477"] # Canonical
  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd-gp3/ubuntu-noble-24.04-amd64-server-*"]
  }
}

resource "aws_security_group" "app" {
  name        = "${var.name}-sg"
  description = "SSH and HTTP"

  ingress {
    description = "SSH"
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  ingress {
    description = "HTTP"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "app" {
  ami                    = data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  key_name               = var.key_name # наявна AWS key pair
  vpc_security_group_ids = [aws_security_group.app.id]
  user_data              = file("${path.module}/user_data.sh")

  root_block_device {
    volume_size = 16
    volume_type = "gp3"
  }

  tags = { Name = var.name }
}
