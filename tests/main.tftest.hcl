provider "acme" {
    server_url = "https://acme-staging-v02.api.letsencrypt.org/directory"
}

variables {
    acme_registration_email = "my-exam@example.com"
    dns_challenges = {
        "dynu" = {
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

run "setup_tests" {
    module {
        source = "./tests/setup"
    }
}

run "test_acme_certificate_count" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
    }

    assert {
        condition     = length(acme_certificate.main) == 3
        error_message = "invalid resource length for acme_certificate.main"
    }

}

run "test_acme_certificate_attribute_name" {
    command = plan
    variables {
        acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
        certificate_signing_requests = run.setup_tests.certificate_signing_requests
    }

    assert {
        condition     = contains(keys(acme_certificate.main), "my_cert_id:main")
        error_message = "attribute my_cert_id:main not found in acme_certificate.main"
    }

    assert {
        condition     = contains(keys(acme_certificate.main), "my_cert_id:main2")
        error_message = "attribute my_cert_id:main2 not found in acme_certificate.main"
    }

    assert {
        condition     = contains(keys(acme_certificate.main), "my_cert_id2:main")
        error_message = "attribute my_cert_id2:main not found in acme_certificate.main"
    }
}

# The following are integration testing and requires secrets.
# For now commenting them out until that can be sorted
// run "test_certificate_issuing" {
//     command = apply
//     variables {
//         acme_registration_account_key_pem = run.setup_tests.acme_registration_account_key_pem
//         certificate_signing_requests = {
//             my_cert_id = {
//                 csr_files = [run.setup_tests.certificate_signing_requests["my_cert_id"]["csr_files"][0]]
//             }
//         }
//         deploy_local_file_path = "tests/deploy_local_file/"
//     }

//     assert {
//         condition     = acme_certificate.main["my_cert_id:main"].certificate_domain == "ha.digimach.com"
//         error_message = "certificate_domain is invalid in resource acme_certificate.main[\"my_cert_id:main\"]"
//     }

//     assert {
//         condition     = output.certs["my_cert_id:main"].certificate_domain == "ha.digimach.com"
//         error_message = "certificate_domain is invalid in output"
//     }

//     expect_failures = [
//         acme_certificate.main["my_cert_id:main"],
//     ]
// }

// run "test_issued_certificate" {
//     module {
//         source = "./tests/post-issue"
//     }
//     variables {
//         issued_cert_pem = run.test_certificate_issuing.certs["my_cert_id:main"].certificate_pem
//     }
//     assert {
//         condition     = output.issued_cert.subject == "CN=ha.digimach.com"
//         error_message = "certificate_domain is invalid in output"
//     }

//     assert {
//         condition     = output.issued_cert.not_after == run.test_certificate_issuing.certs["my_cert_id:main"].certificate_not_after
//         error_message = "certificate expiry (not after) does not match"
//     }
// }

