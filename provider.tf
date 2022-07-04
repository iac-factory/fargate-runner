terraform {
    required_providers {
        aws = {
            version = " >= 4"
        }
    }
}

provider "aws" {
    shared_config_files      = [ "~/.aws/config" ]
    shared_credentials_files = [ "~/.aws/credentials" ]
    profile                  = (var.environment == "Production" || var.environment == "UAT" || var.environment == "Pre-Production") ? "production" : "default"

    skip_metadata_api_check = true

    default_tags {
        tags = module.parameter.tags
    }
}
