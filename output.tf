output "alb_dns_name" {
  value       = aws_lb.example.dns_name
  description = "このサーバー群のロードバランサーのドメイン名"
}

output "url" {
  value = "http://${aws_lb.example.dns_name}"
  description = "このサーバー群のURL"
}