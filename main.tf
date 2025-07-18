provider "aws" {
   region = "ap-northeast-1"
   profile = "study-user"
   assume_role {
     role_arn = "arn:aws:iam::171824085810:role/TerraformExecutionRole"
   }
}

resource "aws_instance" "example" {
  ami           = "ami-054400ced365b82a0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = <<-EOF
              #!/bin/bash
              echo "hello,world" > index.html
              nohup busybox httpd -f -p 8080 &
              EOF
  user_data_replace_on_change = true
  tags = {
    Name = "terraform-example"
  }
}

resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = 8080
    to_port   = 8080
    protocol = "tcp"
    cidr_blocks = [ "0.0.0.0/0" ]
  }
}