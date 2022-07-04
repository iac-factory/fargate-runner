locals {
    defaults = {
        lexical-order      = [ "namespace", "environment", "application", "service", "attributes" ]
        regular-expression = "/[^-a-zA-Z0-9]/"
        delimiter          = "-"
        replacement        = ""
        id-length-limit    = 0
        id-hash-length     = 5
        label-key-casing   = "title"
        label-value-casing = "title"
        prefix-delimiter   = false
    }

    default-label-tag-injection = keys(local.tag-context)

    context-label-tag-injection_is_unset = try(contains(var.context.label-tag-injection, "unset"), true)
    replacement                          = local.defaults.replacement
    id-hash-length                       = local.defaults.id-hash-length

    input = {
        prefix-delimiter = var.prefix-delimiter == null ? var.context.prefix-delimiter : var.prefix-delimiter
        enabled     = var.enabled == null ? var.context.enabled : var.enabled
        tf          = var.tf == null ? var.context.tf : var.tf
        namespace   = var.namespace == null ? var.context.namespace : var.namespace
        environment = var.environment == null ? var.context.environment : var.environment
        service     = var.service == null ? var.context.service : var.service
        application = var.application == null ? var.context.application : var.application
        delimiter   = var.delimiter == null ? var.context.delimiter : var.delimiter
        attributes  = compact(distinct(concat(coalesce(var.context.attributes, [ ]), coalesce(var.attributes, [ ]))))
        tags        = merge(var.context.tags, var.tags)

        metadata-tag-map   = merge(var.context.metadata-tag-map, var.metadata-tag-map)
        lexical-order      = var.lexical-order == null ? var.context.lexical-order : var.lexical-order
        regular-expression = var.regular-expression == null ? var.context.regular-expression : var.regular-expression
        id-length-limit    = var.id-length-limit == null ? var.context.id-length-limit : var.id-length-limit
        label-key-casing   = var.label-key-casing == null ? lookup(var.context, "label-key-casing", null) : var.label-key-casing
        label-value-casing = var.label-value-casing == null ? lookup(var.context, "label-value-casing", null) : var.label-value-casing

        descriptor-formats  = merge(lookup(var.context, "descriptor-formats", {}), var.descriptor-formats)
        label-tag-injection = local.context-label-tag-injection_is_unset ? var.label-tag-injection : var.context.label-tag-injection
    }


    enabled              = local.input.enabled
    prefix-delimiter     = local.input.prefix-delimiter
    regular-expression   = coalesce(local.input.regular-expression, local.defaults.regular-expression)
    string-label-names   = [ "namespace", "environment", "service", "application" ]
    normalize-labels     = { for k in local.string-label-names : k => local.input[ k ] == null ? "" : replace(local.input[ k ], local.regular-expression, local.replacement) }
    normalize-attributes = compact(distinct([ for v in local.input.attributes : replace(v, local.regular-expression, local.replacement) ]))

    format-labels = { for k in local.string-label-names : k => local.label-value-casing == "none" ? local.normalize-labels[ k ] : local.label-value-casing == "title" ? title(lower(local.normalize-labels[ k ])) : local.label-value-casing == "upper" ? upper(local.normalize-labels[ k ]) : lower(local.normalize-labels[ k ]) }

    attributes = compact(distinct([ for v in local.normalize-attributes : (local.label-value-casing == "none" ? v : local.label-value-casing == "title" ? title(lower(v)) : local.label-value-casing == "upper" ? upper(v) : lower(v)) ]))

    tf          = "True"
    namespace   = local.format-labels[ "namespace" ]
    environment = local.format-labels[ "environment" ]
    service     = local.format-labels[ "service" ]
    application = local.format-labels[ "application" ]

    delimiter          = local.input.delimiter == null ? local.defaults.delimiter : local.input.delimiter
    lexical-order      = local.input.lexical-order == null ? local.defaults.lexical-order : coalescelist(local.input.lexical-order, local.defaults.lexical-order)
    id-length-limit    = local.input.id-length-limit == null ? local.defaults.id-length-limit : local.input.id-length-limit
    label-key-casing   = local.input.label-key-casing == null ? local.defaults.label-key-casing : local.input.label-key-casing
    label-value-casing = local.input.label-value-casing == null ? local.defaults.label-value-casing : local.input.label-value-casing

    label-tag-injection = contains(local.input.label-tag-injection, "default") ? local.default-label-tag-injection : local.input.label-tag-injection

    descriptor-formats = local.input.descriptor-formats

    metadata-tag-map = merge(var.context.metadata-tag-map, var.metadata-tag-map)

    tags = merge(local.generator, local.input.tags)

    tag-mapping = flatten([
    for key in keys(local.tags) : merge(
        {
            Key   = key
            Value = local.tags[ key ]
        }, local.metadata-tag-map)
    ])

    tag-context = {
        namespace   = local.namespace
        environment = local.environment
        service     = local.service
        application = local.application
        attributes  = local.id-context.attributes

        name = local.id

        tf = local.tf
    }

    generator = {
    for tag in setintersection(keys(local.tag-context), local.label-tag-injection) :
    local.label-key-casing == "upper" ? upper(tag) : (
    local.label-key-casing == "lower" ? lower(tag) : title(lower(tag))
    ) => local.tag-context[ tag ] if length(local.tag-context[ tag ]) > 0
    }

    id-context = {
        namespace   = local.namespace
        environment = local.environment
        service     = local.service
        application = local.application
        attributes  = join(local.delimiter, local.attributes)
    }

    labels = [ for l in local.lexical-order : local.id-context[ l ] if length(local.id-context[ l ]) > 0 ]

    id-full = join(local.delimiter, local.labels)

    delimiter-length = length(local.delimiter)

    id-truncated-length-limit = local.id-length-limit - (local.id-hash-length + local.delimiter-length)

    id-truncated = local.id-truncated-length-limit <= 0 ? "" : "${trimsuffix(substr(local.id-full, 0, local.id-truncated-length-limit), local.delimiter)}${local.delimiter}"

    id-hash-extension = md5(local.id-full)

    id-hash-string-cast = local.label-value-casing == "title" ? title(local.id-hash-extension) : local.label-value-casing == "upper" ? upper(local.id-hash-extension) : local.label-value-casing == "lower" ? lower(local.id-hash-extension) : local.id-hash-extension
    id-hash             = replace(local.id-hash-string-cast, local.regular-expression, local.replacement)

    id-short = substr("${local.id-truncated}${local.id-hash}", 0, local.id-length-limit)
    id-target       = local.id-length-limit != 0 && length(local.id-full) > local.id-length-limit ? local.id-short : local.id-full
    id = (local.prefix-delimiter) ? join(local.delimiter, ["", local.id-target]) : local.id-target

    output = {
        enabled             = local.enabled
        namespace           = local.namespace
        environment         = local.environment
        service             = local.service
        application         = local.application
        delimiter           = local.delimiter
        attributes          = local.attributes
        tags                = local.tags
        metadata-tag-map    = local.metadata-tag-map
        lexical-order       = local.lexical-order
        regular-expression  = local.regular-expression
        id-length-limit     = local.id-length-limit
        label-key-casing    = local.label-key-casing
        label-value-casing  = local.label-value-casing
        label-tag-injection = local.label-tag-injection
        descriptor-formats  = local.descriptor-formats
    }

}
