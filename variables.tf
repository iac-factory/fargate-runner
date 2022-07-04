variable "namespace" {
    description = "Organization Name or Globally Unique Prefix"
    default = "CI-CD"
    type        = string
}

variable "environment" {
    description = "Target Cloud Environment"
    default = "Development"
    type        = string
}

variable "application" {
    description = "Application Name"
    default = "GitLab"
    type        = string
}

variable "service" {
    description = "Application's Service Name"
    default = "Runner"
    type        = string
}

variable "vpc-name" {
    description = "VPC Name Tag"
    type = string
}

variable "vcs-metadata" {
    description = "VCS Metadata"
    type        = object({
        gitlab = object({ url = string, group = string, project = string }),
        github = object({ url = string, organization = string, repository = string })
    })

    default = null
}

variable "boundary" {
    type = bool
    description = "Allow Actions to Only the Instantiated Master Instance's AWS Account"
    default = false
}