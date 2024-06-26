module "acme_certificates" {
  source                            = "komailo/acme-certificates/modules"
  acme_registration_account_key_pem = tls_private_key.acme_registration_private_key.private_key_pem
  acme_registration_email           = "noreply@example.com"

  certificate_signing_requests = local.certificate_signing_requests

  deploy_local_file_path = "${path.root}/deploy_local_file"

  dns_challenges = {
    dynu = {
      config = {
        DYNU_API_KEY             = "my-api-key"
        DYNU_HTTP_TIMEOUT        = "10"
        DYNU_POLLING_INTERVAL    = "10"
        DYNU_PROPAGATION_TIMEOUT = "600"
        DYNU_TTL                 = "60"
      }
    }
  }
}
