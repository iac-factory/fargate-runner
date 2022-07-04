output "username" {
    value = replace(data.aws_caller_identity.identity.arn, local.iam-arn-prefix, "")
}

output "canonical-id" {
    value = data.aws_canonical_user_id.canonical-user-id.id
}

output "account-id" {
    value = data.aws_caller_identity.identity.account_id
}

output "user-id" {
    value = data.aws_caller_identity.identity.user_id
}

output "arn" {
    value = data.aws_caller_identity.identity.arn
}

output "dns-suffix" {
    value = data.aws_partition.account-partition.dns_suffix
}

output "reverse-dns-prefix" {
    value = data.aws_partition.account-partition.reverse_dns_prefix
}

output "iam-arn-prefix" {
    value = local.iam-arn-prefix
}

output "region" {
    value = data.aws_region.region.name
}