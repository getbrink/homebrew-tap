# Security

This repository is the Homebrew tap for the Brink operator CLI. It holds a formula and a
download strategy, no product code. What it does carry is the checksum a `brew install` trusts.

## Reporting a vulnerability

Email security@getbrink.io. Do not open a public issue for a security report.

You will receive an acknowledgement within three working days. We ask for ninety days before
public disclosure so a fix can ship; we will tell you when it has.

## Scope

- `Formula/brink.rb`: a URL or a `sha256` that does not match the artefact Brink published.
- `lib/custom_download_strategy.rb`, including how it handles the token it is given.
- Anything in the tap that would install a binary other than the released one.

Vulnerabilities in the Brink CLI itself belong to `getbrink/brink`; each product repository
carries its own `SECURITY.md` with the same address.
