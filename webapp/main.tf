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

  root_block_device {
    volume_size = 14
    volume_type = "gp2"
  }

    user_data = <<-EOF
              #!/bin/bash
              # Update packages
              yum update -y
              # Install Docker
              yum install -y docker
              systemctl start docker
              systemctl enable docker
              usermod -aG docker ec2-user
              # Install dependencies
              yum install -y curl git
              # Install Kind
              curl -sLo ./kind https://kind.sigs.k8s.io/dl/v0.26.0/kind-linux-amd64
              chmod +x ./kind
              sudo mv ./kind /usr/local/bin/
              # Install kubectl
              curl -LO https://dl.k8s.io/release/v1.29.13/bin/linux/amd64/kubectl 
              chmod +x ./kubectl
              sudo mv ./kubectl /usr/local/bin/
              sudo yum install -y git
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

resource "aws_ecr_repository" "app_repo" {
  name                 = "application"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}

resource "aws_ecr_repository" "mysql_repo" {
  name                 = "mysql"
  image_tag_mutability = "MUTABLE"
  force_delete = true

  image_scanning_configuration {
    scan_on_push = true
  }
}
