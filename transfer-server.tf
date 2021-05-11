resource "aws_transfer_server" "sftp" {
  identity_provider_type = "API_GATEWAY"
  logging_role           = aws_iam_role.sftp-logging.arn
  url                    = aws_api_gateway_stage.prod.invoke_url
  invocation_role        = aws_iam_role.sftp.arn
  endpoint_type          = var.endpoint_type

  endpoint_details {
    #vpc_endpoint_id = aws_vpc_endpoint.transfer.id
    address_allocation_ids = var.address_allocation_ids
    subnet_ids             = var.public_subnet_ids
    vpc_id                 = var.vpc_id
  }

  tags = {
    NAME = var.name
  }
}

#resource "aws_vpc_endpoint" "transfer" {
#  vpc_id            = var.vpc_id
#  service_name      = "com.amazonaws.${data.aws_region.current.name}.transfer.server"
#  vpc_endpoint_type = "Interface"
#  subnet_ids        = var.public_subnet_ids

#  security_group_ids = [
#    aws_security_group.sftp_sg.id
#  ]

#  tags = {
#    Name = "${var.name}-vpce"
#  }
#}

resource "aws_security_group" "sftp_sg" {
  name        = "sftp-${var.name}-sg"
  description = "SG for SFTP Server"
  vpc_id      = var.vpc_id

  tags = {
    Name = "ftp-${var.name}-sg"
  }
}

resource "aws_security_group_rule" "ip_allowlist" {
  description       = "IP Allow List"
  type              = "ingress"
  protocol          = "TCP"
  to_port           = 22
  from_port         = 22
  cidr_blocks       = split(",", var.ip_allowlist)
  security_group_id = aws_security_group.sftp_sg.id
}

resource "aws_security_group_rule" "egress" {
  description       = "Traffic to internet"
  type              = "egress"
  from_port         = 0
  to_port           = 0
  protocol          = "-1"
  security_group_id = aws_security_group.sftp_sg.id
  cidr_blocks       = ["0.0.0.0/0"]
}


#resource "null_resource" "update-vpc-endpoint-security-group" {
#  provisioner "local-exec" {
#    command = "aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${join("",aws_transfer_server.sftp.endpoint_details.*.vpc_endpoint_id)} --add-security-group-ids '${aws_security_group.sftp_sg.id}' --region ${data.aws_region.current.name}"
#  }
#}

resource "null_resource" "update-vpc-endpoint-security-group" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = <<EOF
set -e

CREDENTIALS=(`aws sts assume-role \
  --role-arn arn:aws:iam::${var.aws_account_id}:role/${var.aws_role} \
  --role-session-name "update-vpc-endpoint-security-group" \
  --query "[Credentials.AccessKeyId,Credentials.SecretAccessKey,Credentials.SessionToken]" \
  --region ap-southeast-2 \
  --output text`)

unset AWS_PROFILE
export AWS_DEFAULT_REGION=ap-southeast-2
export AWS_ACCESS_KEY_ID=$${CREDENTIALS[0]}
export AWS_SECRET_ACCESS_KEY=$${CREDENTIALS[1]}
export AWS_SESSION_TOKEN=$${CREDENTIALS[2]}
export AWS_SECURITY_TOKEN=$${CREDENTIALS[2]}


echo $AWS_ACCESS_KEY_ID
echo $AWS_SECRET_ACCESS_KEY
echo $AWS_SESSION_TOKEN
echo $AWS_SECURITY_TOKEN

aws ec2 modify-vpc-endpoint --vpc-endpoint-id ${join("", aws_transfer_server.sftp.endpoint_details.*.vpc_endpoint_id)} --add-security-group-ids '${aws_security_group.sftp_sg.id}' --region ${data.aws_region.current.name}
EOF
  }
}

resource "aws_route53_record" "sftpserver" {

  zone_id = var.aws_route53_id
  name    = var.custom_domain
  type    = "CNAME"
  ttl     = "60"

  records = [aws_transfer_server.sftp.endpoint]
}