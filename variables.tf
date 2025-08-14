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

variable "my_role_arn" {
  description = "role arn"
  type = string
  default = "arn:aws:iam::171824085810:role/TerraformExecutionRole"
}