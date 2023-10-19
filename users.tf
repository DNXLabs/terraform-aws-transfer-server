data "aws_iam_policy_document" "assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type        = "Service"
      identifiers = ["transfer.amazonaws.com"]
    }
  }
}

data "aws_iam_policy_document" "s3_access_for_sftp_users" {
  for_each  = { for user in var.dynamo_users : user.username => user }

  statement {
    sid    = "AllowListingOfUserFolder"
    effect = "Allow"

    actions = [
      "s3:ListBucket"
    ]

    resources = [
      join("", aws_s3_bucket.sftp[*].arn)
    ]
  }

  statement {
    sid    = "HomeDirObjectAccess"
    effect = "Allow"

    actions = [
      "s3:PutObject",
      "s3:GetObject",
      "s3:DeleteObject",
      "s3:DeleteObjectVersion",
      "s3:GetObjectVersion",
      "s3:GetObjectACL",
      "s3:PutObjectACL"
    ]

    resources = [
      "${join("", aws_s3_bucket.sftp[*].arn)}/${each.value.username}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_access_for_sftp_users" {
  for_each  = { for user in var.dynamo_users : user.username => user }
  name      = "${each.value.username}-s3-access-for-sftp"
  policy    = data.aws_iam_policy_document.s3_access_for_sftp_users[each.value.username].json
}

resource "aws_iam_role" "s3_access_for_sftp_users" {
  for_each            = { for user in var.dynamo_users : user.username => user }
  name                = "${each.value.username}-s3-access-for-sftp"
  assume_role_policy  = join("", data.aws_iam_policy_document.assume_role_policy[*].json)
  managed_policy_arns = [aws_iam_policy.s3_access_for_sftp_users[each.value.username].arn]
}

resource "random_password" "user_password" {
    for_each            = { for user in var.dynamo_users : user.username => user }
  length           = 16
  special          = true
  override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "aws_dynamodb_table_item" "users" {
  for_each            = { for user in var.dynamo_users : user.username => user }
  table_name = aws_dynamodb_table.authentication.name
  hash_key   = aws_dynamodb_table.authentication.hash_key

  item = <<ITEM
{
  "UserId": {"S": "${each.value.username}"},
  "Role": {"S": "${aws_iam_role.s3_access_for_sftp_users[each.value.username].arn}"},
  "Password": {"S": "${random_password.user_password[each.value.username].result}"},
  "HomeDirectory": {"S": "/${aws_s3_bucket.sftp.id}/$${Transfer:UserName}"}
}
ITEM
}