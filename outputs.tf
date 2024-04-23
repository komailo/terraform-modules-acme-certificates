output "certs" {
  value     = acme_certificate.main
  sensitive = true
}
