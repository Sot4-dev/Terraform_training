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
}