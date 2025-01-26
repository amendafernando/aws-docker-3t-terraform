data "terraform_remote_state" "remote_data" {
  backend = "s3"
  config = {
    bucket = "docker-amenda"
    key    = "network/terraform.tfstate"
    region = "us-east-1"
  }
}

resource "aws_instance" "app_server" {
  ami           = var.ami_id
  instance_type = var.instance_type
  subnet_id     = data.terraform_remote_state.remote_data.outputs.subnet_id
  vpc_security_group_ids = [aws_security_group.allow_web.id]
  associate_public_ip_address = true
  user_data = <<-EOF
              #!/bin/bash
              yum update -y
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              sudo usermod -aG docker ec2-user
              sudo systemctl restart docker
              EOF
  
  tags = {
    Name = "${var.project_name}-server"
    Environment = var.environment
  }
}


resource "aws_key_pair" "vm_key" {
  key_name   = var.prefix
  public_key = file("${var.prefix}.pub")
}
# ssh-keygen -t rsa -f docker-ecr
# chmod 400 docker-ecr
# ssh -i non-prod ec2-user@<private ip>

resource "aws_security_group" "allow_web" {
  name        = "${var.prefix}-allow-web"
  description = "Allow web traffic"
  vpc_id      = data.terraform_remote_state.remote_data.outputs.vpc_id

  dynamic "ingress" {
    for_each = var.ingress_ports
    content {
      from_port   = ingress.value
      to_port     = ingress.value
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_ecr_repository" "ecr_repo" {
  name                 = "docker_ecr"
  image_tag_mutability = "MUTABLE"

  image_scanning_configuration {
    scan_on_push = true
  }
}