provider "aws" {
   region = var.region
   profile = var.iam_user_name
   assume_role {
     role_arn = var.my_role_arn
   }
}
