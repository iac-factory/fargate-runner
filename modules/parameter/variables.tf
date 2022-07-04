variable "context" {
    type    = any
    default = {
        enabled             = true
        namespace           = null
        environment         = null
        service             = null
        application         = null
        tf                  = null
        delimiter           = null
        attributes          = [ ]
        tags                = {}
        metadata-tag-map    = {}
        regular-expression  = null
        lexical-order       = [ ]
        id-length-limit     = null
        label-key-casing    = null
        label-value-casing  = null
        descriptor-formats  = {}
        label-tag-injection = null
        prefix-delimiter = false
    }

    description = "Singleton Context Object - Strings & Numerics := null for Default(s)"

    validation {
        condition = lookup(var.context, "label-key-casing", null) == null ? true : contains([
            "lower",
            "title",
            "upper"
        ], var.context[ "label-key-casing" ])
        error_message = "Allowed values: `lower`, `title`, `upper`."
    }

    validation {
        condition = lookup(var.context, "label-value-casing", null) == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.context[ "label-value-casing" ])
        error_message = "Allowed Values: `lower`, `title`, `upper`, `none`."
    }
}

variable "prefix-delimiter" {
    type = bool
    default = null
    description = "Prefix the Delimiter to the Start of the ID String"
}

variable "enabled" {
    type        = bool
    default     = null
    description = "Enable or Disable the Parameter Module"
}

variable "tf" {
    type        = string
    description = "Non-ID Element - Tag Setter"
    default     = null
}

variable "namespace" {
    type        = string
    description = "ID Element - A Global-Level Identifier. Company Name, Contracting Firm, or Business-Unit - perhaps Cloud-service are Appropriate"
    default     = null
}

variable "environment" {
    type        = string
    default     = null
    description = "ID Element - \"Development\" | \"QA\" | \"Staging\" | \"UAT\" | \"Pre-Production\" | \"Production\""

    /// validation {
    ///     condition = contains([
    ///         "Development",
    ///         "QA",
    ///         "Staging",
    ///         "UAT",
    ///         "Pre-Production",
    ///         "Production"
    ///     ], var.environment)
    ///     error_message = "Allowed Values: \"Development\" | \"QA\" | \"Staging\" | \"UAT\" | \"Pre-Production\" | \"Production\"."
    /// }
}

variable "service" {
    type        = string
    default     = null
    description = "ID Element - Service(s) either Consumed or Provided i.e. \"EC2\", \"Custom-Microservice-Name\", \"K8s\""

    /// validation {
    ///     condition     = var.service != null
    ///     error_message = "Service != null"
    /// }
}

variable "application" {
    type        = string
    default     = null
    description = "ID Element - The Component or Solution's Name"

    /// validation {
    ///     condition     = var.service != null
    ///     error_message = "Application != null"
    /// }
}

variable "delimiter" {
    type        = string
    default     = null
    description = "The ID's Element Separator"
}

variable "attributes" {
    type        = list(string)
    default     = [ null ]
    description = "ID Element - Additional attributes (e.g. \"workers\" or \"cluster\") to add to `id`"

    /// validation {
    ///     condition     = var.service != [ null ] && var.service != null
    ///     error_message = "Attribute(s) != null"
    /// }
}

variable "label-tag-injection" {
    type        = set(string)
    default     = [ "default" ]
    description = "ID Element(s) to Include in the ID"
}

variable "tags" {
    type        = map(string)
    default     = {}
    description = "Additional Tags (e.g. `{'BusinessUnit': 'XYZ'}`); Current Tag Keys || Value(s) will not be Modified"
}

variable "metadata-tag-map" {
    type        = map(string)
    default     = {}
    description = "Useful for Output"
}

variable "lexical-order" {
    type        = list(string)
    default     = null
    description = "Element ID Constructor - Defaults to [\"namespace\", \"environment\", \"service\", \"name\", \"attributes\"]"
}

variable "regular-expression" {
    type        = string
    default     = null
    description = "Replacement Pattern - Characters Matching the Expression will be Removed"
}

variable "id-length-limit" {
    type    = number
    default = null
    validation {
        condition     = var.id-length-limit == null ? true : var.id-length-limit >= 6 || var.id-length-limit == 0
        error_message = "The id-length-limit must be >= 6 if supplied (not null), or 0 for unlimited length."
    }
}

variable "label-key-casing" {
    type        = string
    default     = null
    description = "Default := \"upper\"; Possible Values: `lower`, `title`, `upper`."

    validation {
        condition = var.label-key-casing == null ? true : contains([
            "lower",
            "title",
            "upper"
        ], var.label-key-casing)
        error_message = "Allowed values: `lower`, `title`, `upper`."
    }
}

variable "label-value-casing" {
    type        = string
    default     = null
    description = "Default := \"upper\"; Possible Values: `lower`, `title`, `upper`."

    validation {
        condition = var.label-value-casing == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.label-value-casing)
        error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
    }
}

/// Describe additional descriptors to be output in the `descriptors` output map.
/// Map of maps. Keys are names of descriptors. Values are maps of the form
/// `{ format = string labels = list(string) }`
/// (Type is `any` so the map values can later be enhanced to provide additional options.)
/// `format` is a Terraform format string to be passed to the `format()` function.
/// `labels` is a list of labels, in order, to pass to `format()` function.
/// Label values will be normalized before being passed to `format()` so they will be
/// identical to how they appear in `id`.
/// Default is `{}` (`descriptors` output will be empty).

variable "descriptor-formats" {
    type    = any
    default = {}
}
