resource "aws_dynamodb_table" "dynamodb-mimic" {
  name           = "tf-${var.platform_name}"
  billing_mode   = "PROVISIONED"
  read_capacity  = 20
  write_capacity = 20
  hash_key       = "id"

  attribute {
    name = "id"
    type = "S"
  }
}