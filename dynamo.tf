resource "aws_dynamodb_table" "authentication" {
  #count = var.creds_store == "dynamo" ? 1 : 0
  name           = "${var.name}-${var.dynamo_table_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "UserId"

  attribute {
    name = "UserId"
    type = "S"
  }

  tags = {
    Name = "${var.name}-${var.dynamo_table_name}"
  }
}