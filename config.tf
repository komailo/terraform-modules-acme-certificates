terraform {
  required_providers {
    acme = {
      source  = "vancluever/acme"
      version = "~> 3.0"
    }
  }

  required_version = "~> 1.7"
}
