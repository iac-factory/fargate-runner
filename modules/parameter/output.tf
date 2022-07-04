output "tags" {
    value = local.tags
}

output "name" {
    value = local.name
}

output "namespace" {
    value = local.namespace
}

output "environment" {
    value = local.environment
}

output "service" {
    value = local.service
}

output "application" {
    value = local.application
}

output "identifier" {
    value = local.identifier
}

output "input" {
    value = {
        prefix-delimiter = var.prefix-separator
        tf = var.tf
        namespace = var.namespace
        environment = var.environment
        service = var.service
        application = var.application
        separator = var.separator
        tags = var.tags
        casings = var.casings
    }
}