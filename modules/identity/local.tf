locals {
    iam-arn-prefix = join(":", [
        "arn",
        data.aws_partition.account-partition.partition,
        "iam",
        join("", [ ":", data.aws_caller_identity.identity.account_id ])
    ])
}
