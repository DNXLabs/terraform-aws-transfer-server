resource "aws_iam_role" "sftp" {
  name = "${var.name}-transfer-server-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    Name      = "${var.name}-transfer-server-role"
    Terraform = "true"
  }
}


resource "aws_iam_role_policy" "sftp" {
  // policy to allow invocation of IdP API
  name = "${var.name}-sftp-server-iam-policy"
  role = aws_iam_role.sftp.id

  policy = <<POLICY
{
	"Version": "2012-10-17",
	"Statement": [
		{
			"Sid": "InvokeApi",
			"Effect": "Allow",
			"Action": [
				"execute-api:Invoke"
			],
			"Resource": "arn:aws:execute-api:${data.aws_region.current.name}:${data.aws_caller_identity.current.account_id}:${aws_api_gateway_rest_api.sftp-idp-secrets.id}/${aws_api_gateway_stage.prod.stage_name}/GET/*"
		},
		{
			"Sid": "ReadApi",
			"Effect": "Allow",
			"Action": [
				"apigateway:GET"
			],
			"Resource": "*"
		}
	]
}
POLICY
}


resource "aws_iam_role" "sftp-logging" {
  name = "${var.name}-transfer-server-logging-role"

  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": "transfer.amazonaws.com"
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF

  tags = {
    Name      = "${var.name}-transfer-server-logging-role"
    Terraform = "true"
  }
}

resource "aws_iam_role_policy" "sftp-logging" {
  name = "${var.name}-sftp-logging-policy"
  role = aws_iam_role.sftp-logging.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Sid": "VisualEditor0",
            "Effect": "Allow",
            "Action": [
                "logs:CreateLogStream",
                "logs:DescribeLogStreams",
                "logs:CreateLogGroup",
                "logs:PutLogEvents"
            ],
            "Resource": "*"
        }
    ]
}
POLICY

}

