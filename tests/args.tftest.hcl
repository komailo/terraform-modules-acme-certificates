provider "acme" {
    server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

run "setup_tests" {
    module {
        source = "./tests/setup"
    }
}

run "test_defaults_on_acme_certificate" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        acme_registration_email = "hello@example.com"
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
        dns_challenges = {
            "foo" = {
                config = {
                    FOO_ENV_VAR             = "5678"

                }
            }
        }
        
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].cert_timeout == 30
        error_message = "Default value for cert_timeout does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].min_days_remaining == 30
        error_message = "Default value for min_days_remaining does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].pre_check_delay == 0
        error_message = "Default value for pre_check_delay does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].recursive_nameservers == null
        error_message = "Default value for recursive_nameservers does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].revoke_certificate_on_destroy == true
        error_message = "Default value for revoke_certificate_on_destroy does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].revoke_certificate_reason == null
        error_message = "Default value for revoke_certificate_reason does not match input value"
    }
}

run "test_input_args_to_acme_registration" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        acme_registration_email = "hello@example.com"
        acme_registration_external_account_binding = {
            key_id = "key_id"
            hmac_base64 = "hmac_base64"
        }
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
        dns_challenges = {
            "foo" = {
                config = {
                    FOO_ENV_VAR             = "5678"

                }
            }
        }
    }

    assert {
        condition     = acme_registration.main.account_key_pem == run.setup_tests.acme_registration_account_key_pem
        error_message = "Value for account_key_pem does not match input value"
    }

    assert {
        condition     = acme_registration.main.email_address == "hello@example.com"
        error_message = "Value for email_address does not match input value"
    }

    assert {
        condition     = acme_registration.main.external_account_binding[0].key_id == "key_id"
        error_message = "Value for external_account_binding.key_id does not match input value"
    }

    assert {
        condition     = acme_registration.main.external_account_binding[0].hmac_base64 == "hmac_base64"
        error_message = "Value for external_account_binding.hmac_base64 does not match input value"
    }

}

run "test_input_args_to_acme_certificate" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        acme_registration_email = "hello@example.com"
        cert_timeout = 70
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
        dns_challenges = {
            "foo" = {
                config = {
                    FOO_ENV_VAR             = "5678"

                }
            }
        }
        min_days_remaining = 5
        pre_check_delay = 7
        recursive_nameservers = ["a", "b"]
        revoke_certificate_on_destroy = false
        revoke_certificate_reason = "key-compromise"
        
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].account_key_pem == run.setup_tests.acme_registration_account_key_pem
        error_message = "Value for account_key_pem in acme_certificate does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].cert_timeout == var.cert_timeout
        error_message = "Value for cert_timeout does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].min_days_remaining == var.min_days_remaining
        error_message = "Value for min_days_remaining does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].pre_check_delay == var.pre_check_delay
        error_message = "Value for pre_check_delay does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].recursive_nameservers == var.recursive_nameservers
        error_message = "Value for recursive_nameservers does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].revoke_certificate_on_destroy == var.revoke_certificate_on_destroy
        error_message = "Value for revoke_certificate_on_destroy does not match input value"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].revoke_certificate_reason == var.revoke_certificate_reason
        error_message = "Value for revoke_certificate_reason does not match input value"
    }
}
