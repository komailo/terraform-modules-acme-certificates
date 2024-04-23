resource "local_file" "ca_pem" {
  for_each        = var.no_deploy_local_file_ca_pem == true || var.deploy_local_file_path == null ? {} : acme_certificate.main
  content         = acme_certificate.main[each.key].issuer_pem
  filename        = "${var.deploy_local_file_path}/${each.value.certificate_domain}/${split(":", each.key)[1]}.ca.cer"
  depends_on      = [acme_certificate.main]
  file_permission = "0600"
}

resource "local_file" "full_chain" {
  for_each        = var.no_deploy_local_file_full_chain == true || var.deploy_local_file_path == null ? {} : acme_certificate.main
  content         = "${acme_certificate.main[each.key].certificate_pem}${acme_certificate.main[each.key].issuer_pem}"
  filename        = "${var.deploy_local_file_path}/${each.value.certificate_domain}/${split(":", each.key)[1]}.fullchain.cer"
  depends_on      = [acme_certificate.main]
  file_permission = "0600"
}

resource "local_file" "issued_certificate_pem" {
  for_each        = var.no_deploy_local_file_issued_certificate_pem == true || var.deploy_local_file_path == null ? {} : acme_certificate.main
  content         = acme_certificate.main[each.key].certificate_pem
  filename        = "${var.deploy_local_file_path}/${each.value.certificate_domain}/${split(":", each.key)[1]}.cer"
  depends_on      = [acme_certificate.main]
  file_permission = "0600"
}
