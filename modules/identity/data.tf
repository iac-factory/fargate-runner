data "aws_caller_identity" "identity" {}

data "aws_partition" "account-partition" {}

data "aws_canonical_user_id" "canonical-user-id" {}

data "aws_region" "region" {}