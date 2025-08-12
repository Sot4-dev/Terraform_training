provider "aws" {
   region = "ap-northeast-1"
   profile = "study-user"
   assume_role {
     role_arn = "arn:aws:iam::171824085810:role/TerraformExecutionRole"
   }
}
