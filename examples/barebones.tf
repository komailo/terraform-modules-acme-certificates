# Create a private key and manage it via Terraform
# Alternately you could create one securely and provide it as a PEM string to the module
resource "tls_private_key" "acme_registration_private_key" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

locals {
  # dir where all CSR files are placed. You can use any directory structure you like.
  csr_dirs = path.root

  certificate_signing_requests = {
    "example.com" = {
      csr_files = [fileset(local.csr_dirs, "example.com/*.csr")]
    }
  }
}
