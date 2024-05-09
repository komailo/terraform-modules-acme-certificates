provider "acme" {
    server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

run "setup_tests" {
    module {
        source = "./tests/setup"
    }
}

run "test_deploy_local_file_with_certs_home_path" {
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
        deploy_local_file_path = "/tmp/foo"
    }

    assert {
        condition     = local_sensitive_file.full_chain["my_cert_id:main2"] != null
        error_message = "local_sensitive_file.full_chain is null"
    }

    assert {
        condition     = local_sensitive_file.issued_certificate_pem["my_cert_id:main2"] != null
        error_message = "local_sensitive_file.issued_certificate_pem is null"
    }

    assert {
        condition     = local_sensitive_file.ca_pem["my_cert_id:main2"] != null
        error_message = "local_sensitive_file.ca_pem is null"
    }

}

run "test_no_deploy_local_file" {
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
        deploy_local_file_path = null
    }

    assert {
        condition     = length(local_sensitive_file.full_chain) == 0
        error_message = "local_sensitive_file.full_chain is not empty"
    }

    assert {
        condition     = length(local_sensitive_file.issued_certificate_pem) == 0
        error_message = "local_sensitive_file.issued_certificate_pem is not empty"
    }

    assert {
        condition     = length(local_sensitive_file.ca_pem) == 0
        error_message = "local_sensitive_file.ca_pem is not empty"
    }

}
