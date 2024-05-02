variable "acme_registration_account_key_pem" {
  description = "The private key used to identify the account."
  type        = string
  sensitive   = true
}

variable "acme_registration_email" {
  description = "The email address to use for ACME registration"
  type        = string
}

variable "acme_registration_external_account_binding" {
  description = "An external account binding for the registration, usually used to link the registration with an account in a commercial CA."
  type = object({
    key_id      = string
    hmac_base64 = string
  })
  default = null
}

variable "cert_timeout" {
  description = "The timeout for certificate issuance in seconds."
  type        = number
  default     = null

}

variable "certificate_signing_requests" {
  description = "The CSRs metadata to generate certificates for. This does contain the actual CSRs but the pointer to the CSRs in the filesystem."
  type = map(object({
    csr_files = list(string)
  }))

  validation {
    condition = alltrue(
      [for csr_file in flatten([for item in var.certificate_signing_requests : item.csr_files]) : replace(basename(csr_file), ".csr", "") != "latest"]
    )
    error_message = "The csr_files list must not contain a file named 'latest'."
  }

  validation {
    condition = alltrue(
      [for csr_file in flatten([for item in var.certificate_signing_requests : item.csr_files]) : !strcontains(replace(basename(csr_file), ".csr", ""), ":")]
    )
    error_message = "The csr_files list must not contain a file with : (colan) in the file name"
  }

  validation {
    condition = alltrue(
      [for key in keys(var.certificate_signing_requests) : !strcontains(key, ":")]
    )
    error_message = "The certificate ID or the key must not contain : (colan) in the name"
  }
}

variable "disable_complete_propagation" {
  description = "Disable the requirement for full propagation of the TXT challenge records before proceeding with validation."
  type        = bool
  default     = false
}

variable "dns_challenges" {
  description = "The DNS challenges to use in fulfilling the request, multiple DNS providers can be specified. See [Using DNS challenges](https://registry.terraform.io/providers/vancluever/acme/latest/docs/resources/certificate#using-dns-challenges) for more details."
  type = map(object({
    config = optional(map(string))
  }))
}

variable "min_days_remaining" {
  description = "The minimum number of days remaining on a certificate before it should be renewed. A value of less than 0 means that the certificate will never be renewed."
  type        = number
  default     = 30
}

variable "pre_check_delay" {
  description = "The delay to add after every DNS challenge record to allow for extra time for DNS propagation before the certificate is requested. Use this option if you observe issues with requesting certificates even when DNS challenge records get added successfully. Units are in seconds."
  type        = number
  default     = 0
}

variable "recursive_nameservers" {
  description = "The recursive nameservers to use for DNS resolution"
  type        = list(string)
  default     = null
}

variable "revoke_certificate_on_destroy" {
  description = "Enables revocation of a certificate upon destroy of the attached resource, which includes when a resource is re-created."
  type        = bool
  default     = null
}

variable "revoke_certificate_reason" {
  description = "The reason for revoking the certificate. See [RFC 5280](https://datatracker.ietf.org/doc/html/rfc5280#section-5.3.1) for more details. See [upstream](https://registry.terraform.io/providers/xaevman/acme/latest/docs/resources/certificate#revoke_certificate_reason) documentation for more details."
  type        = string
  default     = null
}

# deploy local file variables
variable "deploy_local_file_path" {
  description = "The local path to the directory to write the certificates to. Individual certificates will be written to subdirectories of this path named after the subject of the CSR."
  type        = string
  default     = null
}

variable "no_deploy_local_file_full_chain" {
  description = "If true, the full chain, which includes the CA certificate and signed certificate, will not be written to disk to the path specified in certs_home_path"
  type        = bool
  default     = false
}

variable "no_deploy_local_file_issued_certificate_pem" {
  description = "If true, the CA signed certificate will not be written to disk to the path specified in certs_home_path"
  type        = bool
  default     = false
}

variable "no_deploy_local_file_ca_pem" {
  description = "If true, the CA certificate will not be written to disk to the path specified in certs_home_path"
  type        = bool
  default     = false
}
