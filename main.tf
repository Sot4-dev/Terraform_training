provider "aws" {
   region = "ap-northeast-1"
   profile = "study-user"
   assume_role {
     role_arn = "arn:aws:iam::171824085810:role/TerraformExecutionRole"
   }
}

data "aws_vpc" "default" {
  default = true
}

data "aws_subnets" "default" {
  filter {
    name = "vpc-id"
    values = [ data.aws_vpc.default.id ]
  }
}
variable "server_port" {
  description = "HTTPリクエストに使うポート番号"
  type        = number
  default     = 8080
}

variable "alb_port" {
  description = "ALBのポート"
  type = number
  default = 80
}

variable "ANYWHERE_IPV4_CIDR" {
  description = "インターネットからのアクセスを許可するための0.0.0.0/0"
  type = list(string)
  default = ["0.0.0.0/0"]
}

output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "このサーバー群のロードバランサーのドメイン名"
}

output "url" {
  value = "http://${aws_lb.example.dns_name}"
  description = "このサーバー群のURL"
}
resource "aws_launch_template" "example" {
  name_prefix = "example-"
  image_id           = "ami-054400ced365b82a0"
  instance_type = "t2.micro"
  vpc_security_group_ids = [ aws_security_group.instance.id ]

  user_data = base64encode(<<-EOF
    #!/bin/bash
    echo "hello,world" > index.html
    nohup busybox httpd -f -p ${var.server_port} &
    EOF
  )

  tag_specifications {
    resource_type = "instance"
    tags = {
      Name = "terraform-asg-example"
    }
  }
  #autoscaling groupがある起動設定を使った場合に必須
  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "example" {
  launch_template {
    id = aws_launch_template.example.id
    version = "$Latest"
  }
  vpc_zone_identifier = data.aws_subnets.default.ids
  target_group_arns = [ aws_lb_target_group.asg.arn ]
  health_check_type = "ELB"

  min_size = 2
  max_size = 10
  tag {
    key = "Name"
    value = "terraform-asg-group-example"
    propagate_at_launch = false
  }
}
resource "aws_security_group" "instance" {
  name = "terraform-example-instance"

  ingress {
    from_port = var.server_port
    to_port   = var.server_port
    protocol = "tcp"
    cidr_blocks = var.ANYWHERE_IPV4_CIDR
  }
}

resource "aws_lb" "example" {
  name = "terraform-asg-exam"
  load_balancer_type = "application"
  subnets = data.aws_subnets.default.ids
  security_groups = [ aws_security_group.alb.id ]
}

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.example.arn
  port = 80
  protocol = "HTTP"

  default_action {
    type = "fixed-response"
    fixed_response {
      content_type = "text/plain"
      message_body = "404: page not found"
      status_code = 404
    }
  }
}


resource "aws_security_group" "alb" {
  name = "terraform-example-alb"
  ingress{
    from_port = var.alb_port
    to_port = var.alb_port
    protocol = "tcp"
    cidr_blocks = var.ANYWHERE_IPV4_CIDR
  }

  egress{
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = var.ANYWHERE_IPV4_CIDR
  }
}

resource "aws_lb_target_group" "asg" {
  name = "terraform-asg-example"
  port = var.server_port
  protocol = "HTTP"
  vpc_id = data.aws_vpc.default.id

  health_check {
    path = "/"
    protocol = "HTTP"
    matcher = "200"
    interval = 15
    timeout = 3
    healthy_threshold = 2
    unhealthy_threshold = 2
  }
}

resource "aws_lb_listener_rule" "asg" {
  listener_arn = aws_lb_listener.http.arn
  priority = 100
  condition {
    path_pattern {
      values = [ "*" ]
    }
  }
  action {
    type = "forward"
    target_group_arn = aws_lb_target_group.asg.arn
  }
}