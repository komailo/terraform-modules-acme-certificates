<!-- BEGIN_TF_DOCS -->

# Terraform Modules: ACME Certificate Issuing and Deployment

> :warning: This project is in active development. A proper release process will be added shortly. In the meantime, make sure you [select a ref](https://developer.hashicorp.com/terraform/language/modules/sources#selecting-a-revision) based on a commit SHA to avoid breaking your Terraform pipelines.

This Terraform module simplifies the process of obtaining a signed certificate from an ACME server and deploying it to one of the supported destinations. While ACME protocol provides multiple methods to validate control of the domain in the subject for which the certificate is being issued, this module only interfaces with DNS validation.

Key Features:

- Secure: The private key is not required. A CSR is provided to the module which is used to obtain a signed certificate.
- Renewal on apply: Certificates are renewed on plan apply.
- Infrastructure as Code: Define your ACME certificates in code and manage them via Terraform.

## Quick Start Guide

### Single Project

```hcl
module "cloudflare_pages_hugo_project" {
  source       = "github.com/komailio/terraform-modules-cloudflare-pages-hugo"
  account_id   = "my-cloudflare-account-id"
  project_name = "komailio"
  repo_owner   = "komailo"
  repo_name    = "komail.io"
  custom_domains = [
    # Don't add www records, they will be created for you if `alias_www` is set to true (the default) in the module parameters.
    {
      name    = "komail.io"
      zone_id = "my_zone_id"
    },
  ]
}
```

### Multiple Projects

```hcl
locals {
  account_id = "123456789"
  cloudflare_pages = [
    {
      name       = "komailio"
      repo_owner = "komailo"
      repo_name  = "komail.io"
      custom_domains = [
        # Don't add www records, they will be created for you if `alias_www` is set to true (the default) in the module parameters.
        {
          name    = "komail.io"
          zone_id = "my_zone_id"
        },
      ]
    }
  ]
}

module "cloudflare_pages_hugo_project" {
  for_each       = { for cloudflare_page in local.cloudflare_pages : cloudflare_page.name => cloudflare_page }
  source         = "github.com/komailo/terraform-modules-cloudflare-pages-hugo"
  account_id     = local.account_id
  project_name   = each.key
  repo_owner     = each.value.repo_owner
  repo_name      = each.value.repo_name
  custom_domains = each.value.custom_domains
}
```

## Inputs

| Name                                                                                                                              | Description                                                                                                                                                                                                                                                                                                          | Type                | Default    | Required |
| --------------------------------------------------------------------------------------------------------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------- | ---------- | :------: |
| <a name="input_account_id"></a> [account_id](#input_account_id)                                                                   | The Cloudflare account ID.                                                                                                                                                                                                                                                                                           | `string`            | n/a        |   yes    |
| <a name="input_project_name"></a> [project_name](#input_project_name)                                                             | The name of the Cloudflare pages project.                                                                                                                                                                                                                                                                            | `string`            | n/a        |   yes    |
| <a name="input_repo_name"></a> [repo_name](#input_repo_name)                                                                      | The name of the repository. This is the part after the `repo_owner` in the repository slug.                                                                                                                                                                                                                          | `string`            | n/a        |   yes    |
| <a name="input_repo_owner"></a> [repo_owner](#input_repo_owner)                                                                   | The owner of the repository. This is the very first part of the repository slug.                                                                                                                                                                                                                                     | `string`            | n/a        |   yes    |
| <a name="input_alias_www"></a> [alias_www](#input_alias_www)                                                                      | If true, an alias record (CNAME) `www` will be created for all custom domains                                                                                                                                                                                                                                        | `bool`              | `true`     |    no    |
| <a name="input_build_root_dir"></a> [build_root_dir](#input_build_root_dir)                                                       | The root directory in the repository where the build command should be run. Defaults to the root of the repository.                                                                                                                                                                                                  | `string`            | `""`       |    no    |
| <a name="input_custom_domains"></a> [custom_domains](#input_custom_domains)                                                       | A list of custom domains to associate with the project. Do not add domains with www. prefix here, use the `alias_www` variable instead. Each custom domain must have a `name` and `zone_id` attribute. The `name` attribute is the domain name and the `zone_id` attribute is the Cloudflare zone ID for the domain. | `list(map(string))` | `[]`       |    no    |
| <a name="input_deployments_enabled"></a> [deployments_enabled](#input_deployments_enabled)                                        | Enable deployments for the project.                                                                                                                                                                                                                                                                                  | `bool`              | `true`     |    no    |
| <a name="input_environment_variables"></a> [environment_variables](#input_environment_variables)                                  | A map of environment variables to set for the project in production and preview deployments. The map key is the environment variable name and the value is the environment variable value.                                                                                                                           | `map(string)`       | `{}`       |    no    |
| <a name="input_pr_comments_enabled"></a> [pr_comments_enabled](#input_pr_comments_enabled)                                        | Enable Cloudflare Pages to comment on Pull Requests if preview deployments are enabled.                                                                                                                                                                                                                              | `bool`              | `true`     |    no    |
| <a name="input_preview_environment_variables"></a> [preview_environment_variables](#input_preview_environment_variables)          | A map of environment variables to set for the project in preview deployments in precedence to `environment_variables`. The map key is the environment variable name and the value is the environment variable value.                                                                                                 | `map(string)`       | `{}`       |    no    |
| <a name="input_production_branch"></a> [production_branch](#input_production_branch)                                              | The Git branch to use for production deployments.                                                                                                                                                                                                                                                                    | `string`            | `"main"`   |    no    |
| <a name="input_production_environment_variables"></a> [production_environment_variables](#input_production_environment_variables) | A map of environment variables to set for the project in production deployments in precedence to `environment_variables`. The map key is the environment variable name and the value is the environment variable value.                                                                                              | `map(string)`       | `{}`       |    no    |
| <a name="input_repo_type"></a> [repo_type](#input_repo_type)                                                                      | The SCM platform where the repository is hosted. Valid values are 'github' or 'gitlab'.                                                                                                                                                                                                                              | `string`            | `"github"` |    no    |

## Providers

| Name                                                                  | Version |
| --------------------------------------------------------------------- | ------- |
| <a name="provider_cloudflare"></a> [cloudflare](#provider_cloudflare) | ~> 4.0  |

## Requirements

| Name                                                                        | Version |
| --------------------------------------------------------------------------- | ------- |
| <a name="requirement_terraform"></a> [terraform](#requirement_terraform)    | ~> 1.1  |
| <a name="requirement_cloudflare"></a> [cloudflare](#requirement_cloudflare) | ~> 4.0  |

## Resources

| Name                                                                                                                                                               | Type     |
| ------------------------------------------------------------------------------------------------------------------------------------------------------------------ | -------- |
| [cloudflare_pages_domain.page_domains](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_domain)                           | resource |
| [cloudflare_pages_domain.www_alias](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_domain)                              | resource |
| [cloudflare_pages_project.cloudflare_pages_hugo_github_project](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/pages_project) | resource |
| [cloudflare_record.page_domains](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)                                       | resource |
| [cloudflare_record.www_alias](https://registry.terraform.io/providers/cloudflare/cloudflare/latest/docs/resources/record)                                          | resource |

<!-- END_TF_DOCS -->

## Terraform Cannot Enable Web Analytics

At this time its not possible to enable Web Analytics from Terraform.
The API token permission required is not known. You will have to manually create a Web Analytics resource and use the keys.

https://github.com/cloudflare/terraform-provider-cloudflare/issues/2517#issuecomment-1617849763
https://community.cloudflare.com/t/which-api-token-permissions-are-required-for-cloudflare-web-analytics-site/603102
