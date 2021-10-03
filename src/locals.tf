data "aws_caller_identity" "current" {}

locals {
  prefix = "${data.aws_caller_identity.current.account_id}-tfgoat-aws"

  region = "us-west-2"
}
