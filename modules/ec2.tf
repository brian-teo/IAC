data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = ["ubuntu/images/hvm-ssd/ubuntu-jammy-22.04-amd64-server-*"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"]
}
resource "aws_security_group" "ec2-sg" {
  name   = "new-secgrp"
  vpc_id = module.vpc.vpc_id
  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["10.0.0.0/16"]
  }

  ingress {
    from_port   = 22
    to_port     = 22
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

resource "aws_key_pair" "tf-key-pair" {
  key_name   = "tf-key-pair"
  public_key = tls_private_key.rsa.public_key_openssh
}

resource "tls_private_key" "rsa" {
  algorithm = "RSA"
  rsa_bits  = 4096
}


resource "aws_ssm_parameter" "private" {  
  name  = "/ssh-key-${local.environment}/private/private-key-tf-key-pair"  
  type  = "SecureString"  
  value = tls_private_key.rsa.private_key_pem  
    lifecycle {
          ignore_changes = [  
                value,    
                ]  
              }  
}

resource "aws_ssm_parameter" "public" {  
  name  = "/ssh-key-${local.environment}/public/public-key-tf-key-pair"  
  type  = "SecureString"  
  value = tls_private_key.rsa.public_key_openssh  
  lifecycle {    
            ignore_changes = [
                    value,    
                    ]  
            }  
}

# resource "local_file" "tf-key" {
#   content  = tls_private_key.rsa.private_key_pem
#   filename = "./teo-key-pair"
# }

resource "aws_instance" "this" {
  ami                         = data.aws_ami.ubuntu.id
  instance_type               = "t3.micro"
  subnet_id                   = module.vpc.public_subnets[0]
  key_name                    = "tf-key-pair"
  vpc_security_group_ids      = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true
  root_block_device {
    volume_type           = "gp2"
    volume_size           = "30"
    delete_on_termination = false

  }
}

resource "aws_lb_target_group_attachment" "this" {
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = aws_instance.this.id
  port             = 443
}
output "server_private_ip" {
  value = aws_instance.this.private_ip
}
output "server_public_ipv4" {
  value = aws_instance.this.public_ip
}
output "server_id" {
  value = aws_instance.this.id
}
