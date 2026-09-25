# Contributing to the Brink tap

**`Formula/brink.rb` is generated, not authored.** The `release-brink` workflow in
`getbrink/brink` clones this repository on every CLI release and commits the new version, URLs
and checksums. A hand edit to the formula is overwritten by the next release, so send the change
to the workflow that writes it.

## What a pull request here is for

- `lib/custom_download_strategy.rb`: how release assets are resolved and how the token is
  handled.
- `README.md`: install instructions that do not match what a user actually experiences.
- A formula field the release workflow does not manage.

## Testing a change

```bash
brew tap getbrink/tap
brew install --build-from-source getbrink/tap/brink
brew audit --strict getbrink/tap/brink
brink version
```

Describe the version that ships: no compatibility or migration language, and no instructions for
releases that are no longer current.

## Reporting a bad checksum

A URL or `sha256` that does not match Brink's published artefact is a security report, not a
pull request. See `SECURITY.md`.

## Licence

By contributing you agree that your contribution is licensed under the Apache License 2.0 in
`LICENSE`. Every commit carries a Developer Certificate of Origin sign-off (`git commit -s`).
