## Documentation ##

Documentation is both programmatically and conventionally generated.

**Note** - Given the workflow between `git` & `pre-commit`, when creating
a new commit, ensure to run the following:

```bash
git commit -a --message "..."
```

If a commit shows as a **Failure**, ***such is the job of the pre-commit hook***. 
Simply re-commit and then the repository should be able to be pushed to.

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

It's elected to use `brew uninstall` vs `brew upgrade` because old versions are then removed.

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