# homebrew-tap

Homebrew tap for the Brink operator CLI.

```bash
export HOMEBREW_GITHUB_API_TOKEN=<token with read on getbrink/brink-releases>
brew trust getbrink/tap
brew install getbrink/tap/brink
```

Brink's release artifacts live in the private `getbrink/brink-releases`.
`lib/custom_download_strategy.rb` resolves them through the GitHub release-asset
API using `HOMEBREW_GITHUB_API_TOKEN`. Without a token the install fails with an
explanatory error rather than a bare 404.

## Migrating from the cask

Releases up to `v0.4.5` shipped a cask. Homebrew applies `com.apple.quarantine`
to cask downloads, and macOS refuses to execute a quarantined binary that is not
Apple Developer ID notarized, so that install was broken. Homebrew also declines
to link a formula while a cask of the same name is installed. Remove it first:

```bash
brew uninstall --cask brink
brew install getbrink/tap/brink
```

## Provenance

Both tracked files are generated. `Formula/brink.rb` is written by GoReleaser and
`lib/custom_download_strategy.rb` is synced from
`packaging/homebrew/custom_download_strategy.rb` in `getbrink/brink`, both by the
`release-brink` workflow. Edit them there, not here.
