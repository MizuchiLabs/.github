# Security policy

## Reporting a vulnerability

Please don't open a public issue for a security problem.

- Use "Report a vulnerability" under the "Security and quality" tab of the repository, or
- write to support@mizuchi.dev.

Tell us what you found, which version or commit, and how to reproduce it. A proof of concept helps. A fix is welcome but not needed.

What happens next:

- We confirm that we got the report.
- We tell you whether we can reproduce it and what we plan to do.
- We fix it, release, and publish an advisory. You get credit unless you prefer not to.

We ask for up to 90 days before you publish. If a fix needs longer we will say so and agree on a date with you. If the vulnerability is already being exploited, we publish as soon as a fix or a workaround exists.

## Supported versions

The latest release gets security fixes. Fixes are not backported to older releases.

## Verifying a release

Projects that ship binaries sign their checksum file and container images with cosign from the release workflow. There is no long lived key.

```sh
cosign verify-blob <name>_checksums.txt \
  --bundle <name>_checksums.txt.sigstore.json \
  --certificate-oidc-issuer https://token.actions.githubusercontent.com \
  --certificate-identity-regexp '^https://github\.com/MizuchiLabs/'
sha256sum --check --ignore-missing <name>_checksums.txt
```
