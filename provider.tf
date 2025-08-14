provider "aws" {
   region = "ap-northeast-1"
   profile = "study-user"
   assume_role {
     role_arn = var.my_role_arn
   }
}
