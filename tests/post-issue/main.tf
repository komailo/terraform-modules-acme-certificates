variable "issued_cert_pem" {
  description = "The PEM encoded certificate to use in the test"
  type        = string
  sensitive   = true
}

data "tls_certificate" "issued_cert" {
  content = var.issued_cert_pem
}

output "issued_cert" {
  value     = element(data.tls_certificate.issued_cert.certificates, length(data.tls_certificate.issued_cert.certificates) - 1)
  sensitive = true
}
