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
