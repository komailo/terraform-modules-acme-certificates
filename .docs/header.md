# Terraform Modules: ACME Certificate Issuing and Deployment

> :warning: This project is in active development.

This Terraform module simplifies the process of obtaining a signed certificate from an ACME server and deploying it to one of the supported destinations. While ACME protocol provides multiple methods to validate control of the domain in the subject for which the certificate is being issued, this module only interfaces with DNS validation.

Key Features:

- Secure: The private key is not required. A CSR is provided to the module which is used to obtain a signed certificate.
- Renewal on apply: Certificates are renewed on plan apply.
- Infrastructure as Code: Define your ACME certificates in code and manage them via Terraform.
