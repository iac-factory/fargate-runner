variable "prefix-separator" {
    type = bool
    default = false
    description = "Prefix the Separator to the Start of the ID String"
}

variable "suffix-separator" {
    type = bool
    default = false
    description = "Suffix the Separator to the End of the ID String"
}

variable "tf" {
    type        = string
    description = "Non-ID Element - Tag Setter"
    default     = "True"
}

variable "name-overwrite" {
    type = string
    description = "A Name Tag Escape Hatch - Useful for Larger, Single Resource Terraform Module(s)"
    default = null
}

variable "namespace" {
    type        = string
    description = "ID Element - A Global-Level Identifier. Company Name, Contracting Firm, or Business-Unit - perhaps Cloud-service are Appropriate"
}

variable "environment" {
    type        = string
    default     = "Development"
    description = "ID Element - \"Development\" | \"QA\" | \"Staging\" | \"UAT\" | \"Pre-Production\" | \"Production\""

    validation {
        condition     = var.environment != null
        error_message = "Environment != null"
    }

    // validation {
    //     condition = contains([
    //         "Development",
    //         "QA",
    //         "Staging",
    //         "UAT",
    //         "Pre-Production",
    //         "Production"
    //     ], var.environment)
    //     error_message = "Allowed Values: \"Development\" | \"QA\" | \"Staging\" | \"UAT\" | \"Pre-Production\" | \"Production\"."
    // }
}

variable "service" {
    type        = string
    description = "ID Element - Service(s) either Consumed or Provided i.e. \"EC2\", \"Custom-Microservice-Name\", \"K8s\""

    validation {
        condition     = var.service != null
        error_message = "Service != null"
    }
}

variable "application" {
    type        = string
    description = "ID Element - The Component or Solution's Name"

    validation {
        condition     = var.application != null
        error_message = "Application != null"
    }
}

variable "identifier" {
    type        = string
    description = "ID Element - An Optional Identifier to Further Define the Resource"
    default = null
}

variable "separator" {
    type        = string
    default     = "-"
    description = "The ID's Element Separator"

    validation {
        condition     = var.separator != null
        error_message = "Separator != null"
    }
}

variable "tags" {
    type        = map(string)
    default     = {}
    description = "Additional Tags (e.g. `{'Business-Unit': 'XYZ'}`); Will Overwrite Other Keys Depending on Other Inputs + Tag Keys"
}

variable "casings" {
    type = map(string)

    default = {
        tf = "title"
        namespace = "title"
        environment = "title"
        service = "title"
        application = "title"
        identifier = "title"
        name = "none"
    }

    validation {
        condition = var.casings.application == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.casings.application)
        error_message = "[Application] Allowed values: `lower`, `title`, `upper`, `none`."
    }

//    validation {
//        condition = var.casings.tf == null ? true : contains([
//            "lower",
//            "title",
//            "upper",
//            "none"
//        ], var.casings.tf)
//        error_message = "[TF] Allowed values: `lower`, `title`, `upper`, `none`."
//    }

    validation {
        condition = var.casings.environment == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.casings.environment)
        error_message = "[Environment] Allowed values: `lower`, `title`, `upper`, `none`."
    }

    validation {
        condition = var.casings.namespace == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.casings.namespace)
        error_message = "[Namespace] Allowed values: `lower`, `title`, `upper`, `none`."
    }

    validation {
        condition = var.casings.service == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.casings.service)
        error_message = "[Service] Allowed values: `lower`, `title`, `upper`, `none`."
    }

//    validation {
//        condition = var.casings.identifier == null ? true : contains([
//            "lower",
//            "title",
//            "upper",
//            "none"
//        ], var.casings.identifier)
//        error_message = "[Identifier] Allowed values: `lower`, `title`, `upper`, `none`."
//    }

//    validation {
//        condition = var.casings.name == null ? true : contains([
//            "lower",
//            "title",
//            "upper",
//            "none"
//        ], var.casings.name)
//        error_message = "[Name] Allowed values: `lower`, `title`, `upper`, `none`."
//    }
}

variable "key-casing" {
    type = string
    default = "none"

    validation {
        condition = var.key-casing == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.key-casing)
        error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
    }
}

variable "value-casing" {
    type = string
    default = "none"

    validation {
        condition = var.value-casing == null ? true : contains([
            "lower",
            "title",
            "upper",
            "none"
        ], var.value-casing)
        error_message = "Allowed values: `lower`, `title`, `upper`, `none`."
    }
}