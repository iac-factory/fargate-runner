<!-- BEGIN_TF_DOCS -->
# Test 123 #

## Resources


## Examples

```hcl
provider "aws" {}
```

#### Providers

No providers.



#### Inputs

No inputs.

## Documentation ##

Documentation is both programmatically and conventionally generated.

### Generating `tfvars` & `tfvars.json` ###

```bash
terraform-docs tfvars hcl "$(git rev-parse --show-toplevel)"

terraform-docs tfvars json "$(git rev-parse --show-toplevel)"
```


### `terraform-docs` ###

In order to install `terraform-docs`, ensure `brew` is installed (for MacOS systems), and run

```bash
brew install terraform-docs
```

If looking to upgrade:

```bash
brew uninstall terraform-docs
brew install terraform-docs
```

It's elected to use `brew uninstall` vs `brew upgrade` as any upgrades will still keep old versions on the system.

### `git` & `pre-commit` ###

Documentation is often a second thought; refer to the following steps to ensure documentation is always updated
upon `git commit`.

1. Install Pre-Commit
    ```bash
    brew install pre-commit || pip install pre-commit
    ```
2. Check Installation + Version
    ```bash
    pre-commit --version
    ```
3. Generate Configuration (`.pre-commit-config.yaml`)
    ```yaml
    repos:
        -   repo: https://github.com/terraform-docs/terraform-docs
            rev: "v0.16.0"
            hooks:
                -   id: terraform-docs-go
                    args: ["markdown", "--recursive", "table", "--output-file", "README.md", "."]
    ```
4. Configure `git` hooks
    ```bash
    pre-commit install
    pre-commit install-hooks
    ```
    - If any errors show:
        ```bash
        git config --unset-all core.hooksPath
        ```

**Most Importantly**

> *`pre-commit install` should always be the first command after a project is cloned.*
<!-- END_TF_DOCS -->