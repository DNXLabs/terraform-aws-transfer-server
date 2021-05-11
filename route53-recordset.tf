#resource "aws_route53_record" "sftpserver" {
#  zone_id = var.aws_route53_id
#  name    = "sftp.domain.com"
#  type    = "CNAME"
#  ttl     = "300"

#  records = [aws_transfer_server.sftp.endpoint]
#}