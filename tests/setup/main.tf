locals {
  common_names    = toset(["ha.digimach.com", "snipeit.digimach.com"])
  csr_output_path = "${path.module}/certs"
}

resource "tls_private_key" "main" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_private_key" "acme_registration_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "tls_cert_request" "main" {
  for_each        = local.common_names
  private_key_pem = tls_private_key.main.private_key_pem

  subject {
    common_name = each.value
  }
}

resource "local_file" "main_csr" {
  for_each = local.common_names
  content  = tls_cert_request.main[each.value].cert_request_pem
  filename = "${local.csr_output_path}/${each.value}/main.csr"
}

resource "tls_cert_request" "main2" {
  private_key_pem = tls_private_key.main.private_key_pem

  subject {
    common_name = "ha.digimach.com"
  }
}

resource "local_file" "main_csr2" {
  content  = tls_cert_request.main2.cert_request_pem
  filename = "${local.csr_output_path}/ha.digimach.com/main2.csr"
}

output "certificate_signing_requests" {
  value = {
    "my_cert_id" = {
      csr_files = ["${local.csr_output_path}/ha.digimach.com/main.csr", "${local.csr_output_path}/ha.digimach.com/main2.csr"]
    },
    "my_cert_id2" = {
      csr_files = ["${local.csr_output_path}/snipeit.digimach.com/main.csr"]
    }
  }
}

output "acme_registration_account_key_pem" {
  value     = tls_private_key.acme_registration_private_key.private_key_pem
  sensitive = true
}

