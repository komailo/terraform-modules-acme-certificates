locals {
  csr_files = flatten([
    for csr_id, csr_data in var.certificate_signing_requests : [
      for file in csr_data.csr_files : {
        name = "${csr_id}:${replace(basename(file), ".csr", "")}"
        path = file
      }
    ]
  ])
}

resource "acme_registration" "main" {
  account_key_pem = var.acme_registration_account_key_pem
  email_address   = var.acme_registration_email

  dynamic "external_account_binding" {
    for_each = var.acme_registration_external_account_binding != null ? [1] : []
    content {
      key_id      = var.acme_registration_external_account_binding.key_id
      hmac_base64 = var.acme_registration_external_account_binding.hmac_base64
    }
  }
}

resource "acme_certificate" "main" {
  for_each = { for csr in local.csr_files : csr.name => csr }

  account_key_pem               = acme_registration.main.account_key_pem
  cert_timeout                  = var.cert_timeout
  certificate_request_pem       = file(each.value.path)
  disable_complete_propagation  = var.disable_complete_propagation
  min_days_remaining            = var.min_days_remaining
  pre_check_delay               = var.pre_check_delay
  recursive_nameservers         = var.recursive_nameservers
  revoke_certificate_on_destroy = var.revoke_certificate_on_destroy
  revoke_certificate_reason     = var.revoke_certificate_reason

  dynamic "dns_challenge" {
    for_each = var.dns_challenges
    content {
      provider = dns_challenge.key
      config   = var.dns_challenges[dns_challenge.key].config
    }
  }
}
