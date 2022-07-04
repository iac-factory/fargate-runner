# Changelog #

## `1.1.2` ## 

**Feature: `prefix-delimiter` optional input variable (`boolean`)**

Setting `delimiter-prefix` to `true` will now prefix the entire ID with the delimiter otherwise specified. Bare in mind, the default is `-`,
which is otherwise an odd delimiter to prefix the id-element with. See examples for useful context(s).

### Example ###

```hcl
module "parameter" {
    namespace = var.namespace
    application = var.application
    attributes =  var.attributes
    service = var.service
    environment = var.environment
    delimiter = var.delimiter
    prefix-delimiter = false

    enabled = true
}
```

```hcl
module "parameter-ssm" {
    namespace = var.namespace
    application = var.application
    attributes =  var.attributes
    service = var.service
    environment = var.environment
    delimiter = "/"
    prefix-delimiter = true

    enabled = true
}
```

```hcl
module "parameter-secrets-manager" {
    namespace = var.namespace
    application = var.application
    attributes =  var.attributes
    service = var.service
    environment = var.environment
    delimiter = "/"
    prefix-delimiter = false

    enabled = true
}
```
