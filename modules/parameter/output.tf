output "id" {
    value       = local.enabled ? local.id : ""
    description = "Disambiguated ID restricted to `id-length-limit` Characters in Total"
}

output "id-full" {
    value       = local.enabled ? local.id-full : ""
    description = "ID String without Length Restriction"
}

output "enabled" {
    value       = local.enabled
    description = "True := module == enabled || false"
}

output "namespace" {
    value       = local.enabled ? local.namespace : ""
    description = "Normalized Namespace Value"
}

output "environment" {
    value       = local.enabled ? local.environment : ""
    description = "Normalized Environment Value"
}

output "application" {
    value       = local.enabled ? local.application : ""
    description = "Normalized Name Value"
}

output "service" {
    value       = local.enabled ? local.service : ""
    description = "Normalized service Value"
}

output "delimiter" {
    value       = local.enabled ? local.delimiter : ""
    description = "Delimiter between `namespace`, `environment`, `service`, `name` and `attributes`"
}

output "attributes" {
    value       = local.enabled ? local.attributes : [ ]
    description = "List Tag Defining Attribute(s)"
}

output "tags" {
    value       = local.enabled ? local.tags : {}
    description = "Normalized Tag Mapping"
}

output "metadata-tag-map" {
    value       = local.metadata-tag-map
    description = "The Merged `metadata-tag-map`"
}

output "lexical-order" {
    value       = local.lexical-order
    description = "The ID Naming Order"
}

output "regular-expression" {
    value       = local.regular-expression
    description = "The regular-expression that Creates the ID"
}

output "id-length-limit" {
    value       = local.id-length-limit
    description = "The id-length-limit actually used to create the ID, with `0` meaning unlimited"
}

output "tag-mapping" {
    value       = local.tag-mapping
    description = "Key = [Key], Value = [Value] Mapping"
}

output "normalization-context" {
    value       = local.output
    description = "Normalized Context of the Abstract Module"
}

output "context" {
    value       = local.input
    description = "Merged, Unmodified Module Input for Contextual Input to Other Modules"
}
