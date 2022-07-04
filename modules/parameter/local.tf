locals {
    name-normalize = (var.identifier != null) ? join(var.separator, [
        (var.casings.namespace == "title") ? title(var.namespace) : (var.casings.namespace == "lower") ? lower(var.namespace) : (var.casings.namespace == "upper") ? upper(var.namespace) : var.namespace,
        (var.casings.environment == "title") ? title(var.environment) : (var.casings.environment == "lower") ? lower(var.environment) : (var.casings.environment == "upper") ? upper(var.environment) : var.environment,
        (var.casings.application == "title") ? title(var.application) : (var.casings.application == "lower") ? lower(var.application) : (var.casings.application == "upper") ? upper(var.application) : var.application,
        (var.casings.service == "title") ? title(var.service) : (var.casings.service == "lower") ? lower(var.service) : (var.casings.service == "upper") ? upper(var.service) : var.service,
        (var.casings.identifier == "title") ? title(var.identifier) : (var.casings.identifier == "lower") ? lower(var.identifier) : (var.casings.identifier == "upper") ? upper(var.identifier) : var.identifier,
    ]) : join(var.separator, [
        (var.casings.namespace == "title") ? title(var.namespace) : (var.casings.namespace == "lower") ? lower(var.namespace) : (var.casings.namespace == "upper") ? upper(var.namespace) : var.casings.namespace,
        (var.casings.environment == "title") ? title(var.environment) : (var.casings.environment == "lower") ? lower(var.environment) : (var.casings.environment == "upper") ? upper(var.environment) : var.casings.environment,
        (var.casings.application == "title") ? title(var.application) : (var.casings.application == "lower") ? lower(var.application) : (var.casings.application == "upper") ? upper(var.application) : var.casings.application,
        (var.casings.service == "title") ? title(var.service) : (var.casings.service == "lower") ? lower(var.service) : (var.casings.service == "upper") ? upper(var.service) : var.casings.service,
    ])

    name-separation = (var.prefix-separator == true) ? join(var.separator, ["", local.name-normalize]) : local.name-normalize
    name-separation-ending = (var.suffix-separator == true) ? join(var.separator, [local.name-separation, ""]) : local.name-separation

    name-casing = (var.value-casing == "title") ? title(local.name-separation-ending) : (var.value-casing == "lower") ? lower(local.name-separation-ending) : (var.value-casing == "upper") ? upper(local.name-separation-ending) : local.name-separation-ending

    name = (var.name-overwrite == null) ? try(var.casings.name == "title", false) ? title(local.name-casing) : try(var.casings.name == "lower", false) ? lower(local.name-casing) : try(var.casings.name == "upper", false) ? upper(local.name-casing) : local.name-casing : var.name-overwrite

    /*** The Mapping between Title-Casing-Casts to their Associated User-Defined Input(s) (Variables) */
    tags-normalize = merge({
        TF          = try(var.casings.tf == "title", false) ? title(var.tf) : try(var.casings.tf == "lower", false) ? lower(var.tf) : try(var.casings.tf == "upper", false) ? upper(var.tf) : var.tf
        Namespace   = (var.casings.namespace == "title") ? title(var.namespace) : (var.casings.namespace == "lower") ? lower(var.namespace) : (var.casings.namespace == "upper") ? upper(var.namespace) : var.namespace
        Environment = (var.casings.environment == "title") ? title(var.environment) : (var.casings.environment == "lower") ? lower(var.environment) : (var.casings.environment == "upper") ? upper(var.environment) : var.environment
        Service     = (var.casings.service == "title") ? title(var.service) : (var.casings.service == "lower") ? lower(var.service) : (var.casings.service == "upper") ? upper(var.service) : var.service
        Application = (var.casings.application == "title") ? title(var.application) : (var.casings.application == "lower") ? lower(var.application) : (var.casings.application == "upper") ? upper(var.application) : var.application
        Identifier = (var.identifier != null) ? (var.casings.identifier == "title") ? title(var.identifier) : (var.casings.identifier == "lower") ? lower(var.identifier) : (var.casings.identifier == "upper") ? upper(var.identifier) : var.identifier : null
        Name = try(var.casings.name == "title", false) ? title(local.name) : try(var.casings.name == "lower", false) ? lower(local.name) : try(var.casings.name == "upper", false) ? upper(local.name) : local.name
    }, var.tags)

    /*** The Mapping between Casing-Casts of Keys */
    tags-key-mapping = (var.key-casing == "title") ? { for key in keys(local.tags-normalize) : title(key) => local.tags-normalize[ key ] } : (var.key-casing == "lower") ? { for key in keys(local.tags-normalize) : lower(key) => local.tags-normalize[ key ] } : (var.key-casing == "upper") ? { for key in keys(local.tags-normalize) : upper(key) => local.tags-normalize[ key ] } : { for key in keys(local.tags-normalize) : key => local.tags-normalize[ key ] }
    /*** The Mapping between Casing-Casts of Keys + Values */
    tags-value-mapping = (var.value-casing == "title") ? { for key in keys(local.tags-key-mapping) : key => title(local.tags-key-mapping[ key ]) } : (var.value-casing == "lower") ? { for key in keys(local.tags-key-mapping) : key => lower(local.tags-key-mapping[ key ]) } : (var.value-casing == "upper") ? { for key in keys(local.tags-key-mapping) : key => upper(local.tags-key-mapping[ key ]) } : { for key in keys(local.tags-key-mapping) : key => local.tags-key-mapping[ key ] }

    /*** The Mapping between Casing-Casts of Keys + Values, & User-Defined `tags`, Cleansed of Key-Value Pairs containing NIL */
    tags = (var.value-casing == "title") ? { for key in keys(local.tags-value-mapping) : key => title(local.tags-value-mapping[ key ]) if local.tags-value-mapping[ key ] != null } : (var.value-casing == "lower") ? { for key in keys(local.tags-value-mapping) : key => lower(local.tags-value-mapping[ key ]) if local.tags-value-mapping[ key ] != null } : (var.value-casing == "upper") ? { for key in keys(local.tags-value-mapping) : key => upper(local.tags-value-mapping[ key ]) if local.tags-value-mapping[ key ] != null } : { for key in keys(local.tags-value-mapping) : key => local.tags-value-mapping[ key ] if local.tags-value-mapping[ key ] != null }

    namespace-normalize = (var.key-casing == "title") ? local.tags["Namespace"] : (var.key-casing == "lower") ? local.tags["namespace"] : (var.key-casing == "upper") ? local.tags["NAMESPACE"] : local.tags["Namespace"]
    environment-normalize = (var.key-casing == "title") ? local.tags["Environment"] : (var.key-casing == "lower") ? local.tags["environment"] : (var.key-casing == "upper") ? local.tags["ENVIRONMENT"] : local.tags["Environment"]
    service-normalize = (var.key-casing == "title") ? local.tags["Service"] : (var.key-casing == "lower") ? local.tags["service"] : (var.key-casing == "upper") ? local.tags["SERVICE"] : local.tags["Service"]
    application-normalize = (var.key-casing == "title") ? local.tags["Application"] : (var.key-casing == "lower") ? local.tags["application"] : (var.key-casing == "upper") ? local.tags["APPLICATION"] : local.tags["Application"]
    identifier-normalize = (var.identifier != null) ? (var.key-casing == "title") ? local.tags["Identifier"] : (var.key-casing == "lower") ? local.tags["identifier"] : (var.key-casing == "upper") ? local.tags["IDENTIFIER"] : local.tags["Identifier"] : null

    namespace = (var.casings.namespace == "title") ? title(local.namespace-normalize) : (var.casings.namespace == "lower") ? lower(local.namespace-normalize) : (var.casings.namespace == "upper") ? upper(local.namespace-normalize) : local.namespace-normalize
    environment = (var.casings.environment == "title") ? title(local.environment-normalize) : (var.casings.environment == "lower") ? lower(local.environment-normalize) : (var.casings.environment == "upper") ? upper(local.environment-normalize) : local.environment-normalize
    service = (var.casings.service == "title") ? title(local.service-normalize) : (var.casings.service == "lower") ? lower(local.service-normalize) : (var.casings.service == "upper") ? upper(local.service-normalize) : local.service-normalize
    application = (var.casings.application == "title") ? title(local.application-normalize) : (var.casings.application == "lower") ? lower(local.application-normalize) : (var.casings.application == "upper") ? upper(local.application-normalize) : local.application-normalize
    identifier = (var.identifier != null) ? (var.casings.identifier == "title") ? title(local.identifier-normalize) : (var.casings.identifier == "lower") ? lower(local.identifier-normalize) : (var.casings.identifier == "upper") ? upper(local.identifier-normalize) : local.identifier-normalize : null
}