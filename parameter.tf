module "parameter" {
    source = "./modules/parameter"

    namespace = var.namespace
    environment = var.environment
    service = var.service
    application = var.application
}

module "iam-path" {
    source = "./modules/parameter"

    separator = "/"
    prefix-separator = true
    suffix-separator = true

    namespace = var.namespace
    environment = var.environment
    service = var.service
    application = var.application
}