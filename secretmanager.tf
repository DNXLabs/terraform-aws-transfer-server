
resource "aws_secretsmanager_secret" "secretpassword" {
  name                    = "SFTP/${var.name}-secretpassword"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret" "secretpublickey" {
  name                    = "SFTP/${var.name}-secretpublickey"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "secretpassword" {
  secret_id     = aws_secretsmanager_secret.secretpassword.id
  secret_string = <<EOF
{
  "HomeDirectoryDetails": "[{\"Entry\": \"/\", \"Target\": \"/${aws_s3_bucket.sftp.id}/$${Transfer:UserName}\"}]",
  "Password": "${var.password}",
  "Role": "${aws_iam_role.transfer_user_iam_role.arn}",
  "UserId": "${var.name}-secretpassword"
}
EOF
}

resource "aws_secretsmanager_secret_version" "secretpublickey" {
  secret_id     = aws_secretsmanager_secret.secretpublickey.id
  secret_string = <<EOF
{
  "HomeDirectoryDetails": "[{\"Entry\": \"/\", \"Target\": \"/${aws_s3_bucket.sftp.id}/$${Transfer:UserName}\"}]",
  "PublicKey": "${var.public_key}",
  "Role": "${aws_iam_role.transfer_user_iam_role.arn}",
  "UserId": "${var.name}-secretpublickey"
}
EOF
}

resource "aws_iam_role" "transfer_user_iam_role" {
  name               = "${var.name}-transfer_user_iam_role"
  assume_role_policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
        "Effect": "Allow",
        "Principal": {
            "Service": ["s3.amazonaws.com","transfer.amazonaws.com"]
        },
        "Action": "sts:AssumeRole"
        }
    ]
}
EOF
}


resource "aws_iam_role_policy" "transfer_user_iam_policy" {
  name = "${var.name}-transfer_user_iam_policy"
  role = aws_iam_role.transfer_user_iam_role.id

  policy = <<POLICY
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Action": [
                "s3:ListBucket",
                "s3:GetBucketLocation"
            ],
            "Resource": "${aws_s3_bucket.sftp.arn}",
            "Effect": "Allow",
            "Sid": "AllowListingOfUserFolder"
        },
        {
            "Action": [
                "s3:PutObject",
                "s3:GetObject",
                "s3:DeleteObjectVersion",
                "s3:DeleteObject",
                "s3:GetObjectVersion"
            ],
            "Resource": "${aws_s3_bucket.sftp.arn}/*",
            "Effect": "Allow",
            "Sid": "FTPBucketAccessPolicy"
        }
    ]
}
POLICY
}



