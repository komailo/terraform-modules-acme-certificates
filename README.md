<!-- BEGIN_TF_DOCS -->
# Terraform Modules: ACME Certificate Issuing and Deployment

> :warning: This project is in active development.

This Terraform module simplifies the process of obtaining a signed certificate from an ACME server and deploying it to one of the supported destinations. While ACME protocol provides multiple methods to validate control of the domain in the subject for which the certificate is being issued, this module only interfaces with DNS validation.

Key Features:

- Secure: The private key is not required. A CSR is provided to the module which is used to obtain a signed certificate.
- Renewal on apply: Certificates are renewed on plan apply.
- Infrastructure as Code: Define your ACME certificates in code and manage them via Terraform.

## Quick Start Guide

### Local Filesystem Deployment

```hcl
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
```



## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_acme_registration_account_key_pem"></a> [acme\_registration\_account\_key\_pem](#input\_acme\_registration\_account\_key\_pem) | The private key used to identify the account. | `string` | n/a | yes |
| <a name="input_acme_registration_email"></a> [acme\_registration\_email](#input\_acme\_registration\_email) | The email address to use for ACME registration | `string` | n/a | yes |
| <a name="input_certificate_signing_requests"></a> [certificate\_signing\_requests](#input\_certificate\_signing\_requests) | The CSRs metadata to generate certificates for. This does contain the actual CSRs but the pointer to the CSRs in the filesystem. | <pre>map(object({<br>    csr_files = list(string)<br>  }))</pre> | n/a | yes |
| <a name="input_dns_challenges"></a> [dns\_challenges](#input\_dns\_challenges) | The DNS challenges to use in fulfilling the request, multiple DNS providers can be specified. See [Using DNS challenges](https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#using-dns-challenges) for more details. | <pre>map(object({<br>    config = optional(map(string))<br>  }))</pre> | n/a | yes |
| <a name="input_acme_registration_external_account_binding"></a> [acme\_registration\_external\_account\_binding](#input\_acme\_registration\_external\_account\_binding) | An external account binding for the registration, usually used to link the registration with an account in a commercial CA. | <pre>object({<br>    key_id      = string<br>    hmac_base64 = string<br>  })</pre> | `null` | no |
| <a name="input_cert_timeout"></a> [cert\_timeout](#input\_cert\_timeout) | The timeout for certificate issuance in seconds. | `number` | `null` | no |
| <a name="input_deploy_local_file_path"></a> [deploy\_local\_file\_path](#input\_deploy\_local\_file\_path) | The local path to the directory to write the certificates to. Individual certificates will be written to subdirectories of this path named after the subject of the CSR. | `string` | `null` | no |
| <a name="input_disable_complete_propagation"></a> [disable\_complete\_propagation](#input\_disable\_complete\_propagation) | Disable the requirement for full propagation of the TXT challenge records before proceeding with validation. | `bool` | `false` | no |
| <a name="input_min_days_remaining"></a> [min\_days\_remaining](#input\_min\_days\_remaining) | The minimum number of days remaining on a certificate before it should be renewed. A value of less than 0 means that the certificate will never be renewed. | `number` | `30` | no |
| <a name="input_no_deploy_local_file_ca_pem"></a> [no\_deploy\_local\_file\_ca\_pem](#input\_no\_deploy\_local\_file\_ca\_pem) | If true, the CA certificate will not be written to disk to the path specified in certs\_home\_path | `bool` | `false` | no |
| <a name="input_no_deploy_local_file_full_chain"></a> [no\_deploy\_local\_file\_full\_chain](#input\_no\_deploy\_local\_file\_full\_chain) | If true, the full chain, which includes the CA certificate and signed certificate, will not be written to disk to the path specified in certs\_home\_path | `bool` | `false` | no |
| <a name="input_no_deploy_local_file_issued_certificate_pem"></a> [no\_deploy\_local\_file\_issued\_certificate\_pem](#input\_no\_deploy\_local\_file\_issued\_certificate\_pem) | If true, the CA signed certificate will not be written to disk to the path specified in certs\_home\_path | `bool` | `false` | no |
| <a name="input_pre_check_delay"></a> [pre\_check\_delay](#input\_pre\_check\_delay) | The delay to add after every DNS challenge record to allow for extra time for DNS propagation before the certificate is requested. Use this option if you observe issues with requesting certificates even when DNS challenge records get added successfully. Units are in seconds. | `number` | `0` | no |
| <a name="input_recursive_nameservers"></a> [recursive\_nameservers](#input\_recursive\_nameservers) | The recursive nameservers to use for DNS resolution | `list(string)` | `null` | no |
| <a name="input_revoke_certificate_on_destroy"></a> [revoke\_certificate\_on\_destroy](#input\_revoke\_certificate\_on\_destroy) | Enables revocation of a certificate upon destroy of the attached resource, which includes when a resource is re-created. | `bool` | `null` | no |
| <a name="input_revoke_certificate_reason"></a> [revoke\_certificate\_reason](#input\_revoke\_certificate\_reason) | The reason for revoking the certificate. See [RFC 5280](https://datatracker.ietf.org/doc/html/rfc5280#section-5.3.1) for more details. See [upstream](https://registry.terraform.io/providers/xaevman/acme/latest/docs/resources/certificate#revoke_certificate_reason) documentation for more details. | `string` | `null` | no |



## Outputs

| Name | Description |
|------|-------------|
| <a name="output_certs"></a> [certs](#output\_certs) | n/a |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_acme"></a> [acme](#provider\_acme) | 2.21.0 |
| <a name="provider_local"></a> [local](#provider\_local) | 2.5.1 |

## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | ~> 1.7 |
| <a name="requirement_acme"></a> [acme](#requirement\_acme) | ~> 2.0 |

## Resources

| Name | Type |
|------|------|
| [acme_certificate.main](https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate) | resource |
| [acme_registration.main](https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/registration) | resource |
| [local_sensitive_file.ca_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.full_chain](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
| [local_sensitive_file.issued_certificate_pem](https://registry.terraform.io/providers/hashicorp/local/latest/docs/resources/sensitive_file) | resource |
<!-- END_TF_DOCS -->