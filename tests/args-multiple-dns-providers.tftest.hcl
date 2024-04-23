provider "acme" {
    server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

run "setup_tests" {
    module {
        source = "./tests/setup"
    }
}

run "test_multiple_dns_providers" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
        acme_registration_email = "hello@example.com"
        dns_challenges = {
            "test" = {
                config = {
                    TEST_ENV_VAR             = "1234"
                }
            }
            "foo" = {
                config = {
                    FOO_ENV_VAR             = "5678"

                }
            }
        }
    }
    assert {
        condition     = length(acme_certificate.main["my_cert_id:main2"].dns_challenge) == 2
        error_message = "invalid config length for dns_challenge"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].dns_challenge[0].provider == "foo"
        error_message = "invalid provider value for dns_challenge first element"
    }

    assert {
        condition     = acme_certificate.main["my_cert_id:main2"].dns_challenge[0].config["FOO_ENV_VAR"] == "5678"
        error_message = "invalid config key value for dns_challenge first element config key FOO_ENV_VAR"
    }

}