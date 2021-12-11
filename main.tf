provider "aws" {
  region = "eu-west-1"
}

terraform {

  backend "s3" {
    bucket         = "bucketoftarek8786"
    key            = "terraform.tfstates"
    dynamodb_table = "terraform-lock"
  }
}

#vpc

module "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = "10.0.0.0/16"

  azs            = ["eu-west-1a"]
  public_subnets = ["10.0.1.0/24"]

}

#security group

resource "aws_security_group" "my-sg" {
  vpc_id = module.vpc.vpc_id
  name   = join("_", ["sg", module.vpc.vpc_id])
  dynamic "ingress" {
    for_each = var.rules
    content {
      from_port   = ingress.value["port"]
      to_port     = ingress.value["port"]
      protocol    = ingress.value["proto"]
      cidr_blocks = ingress.value["cidr_blocks"]
    }
  }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "Websecurity-SG"
  }
}

#EC2 instance
resource "aws_instance" "my-instance" {
  ami             = "ami-08edbb0e85d6a0a07" #Ubuntu
  subnet_id       = module.vpc.public_subnets[0]
  instance_type   = "t3.micro"
  key_name        = "new-key-1"
  security_groups = [aws_security_group.my-sg.id]
  tags            = { Name = "static-web" }

}

resource "local_file" "hosts_cfg" {
  content = templatefile("./templates/hosts.tpl",
    {
      instance_address = aws_instance.my-instance.public_ip
    }
  )
  filename = "./inventory/hosts.cfg"
}