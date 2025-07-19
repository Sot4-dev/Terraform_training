provider "aws" {
   region = "ap-northeast-1"
   profile = "study-user"
   assume_role {
     role_arn = "arn:aws:iam::171824085810:role/TerraformExecutionRole"
   }
}

variable "server_port" {
  description = "HTTPリクエストに使うポート番号"
  type        = number
  default     = 8080
}

output "public_ip" {
  value       = aws_instance.example.public_ip
  description = "このサーバーのパブリックIPアドレス"
}

output "url" {
  value = "http://${aws_instance.example.public_ip}:${var.server_port}"
  description = "このサーバーのURL"
}
resource "aws_instance" "example" {
  ami           = "ami-054400ced365b82a0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
              #!/bin/bash
              echo "hello,world" > index.html
              nohup busybox httpd -f -p ${var.server_port} &
              EOF
  user_data_replace_on_change = true
  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}