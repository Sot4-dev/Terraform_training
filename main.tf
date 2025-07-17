provider "aws" {
   region = "ap-northeast-1"
}

resource "aws_instance" "example" {
  ami           = "ami-054400ced365b82a0"
  instance_type = "t2.micro"
}