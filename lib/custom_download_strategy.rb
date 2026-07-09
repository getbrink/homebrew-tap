# typed: false
# frozen_string_literal: true

# Canonical source for getbrink/homebrew-tap:lib/custom_download_strategy.rb.
# The release workflow syncs this file into the tap; edit it here, never there.

require "download_strategy"

# Resolves a release asset in a private GitHub repository. The browser download
# URL that GoReleaser writes into the formula 404s without credentials, so the
# asset id is looked up through the REST API and fetched with an Authorization
# header. Reads HOMEBREW_GITHUB_API_TOKEN from the caller's environment.
class GitHubPrivateRepositoryReleaseDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    @url = url
    parse_url_pattern
    @github_token = ENV.fetch("HOMEBREW_GITHUB_API_TOKEN", nil)
    if @github_token.nil? || @github_token.empty?
      raise CurlDownloadStrategyError, <<~MSG
        brink release artifacts are hosted in the private repository #{@owner}/#{@repo}.
        Set HOMEBREW_GITHUB_API_TOKEN to a GitHub token with read access to it:

          export HOMEBREW_GITHUB_API_TOKEN=<token>
          brew install getbrink/tap/brink
      MSG
    end
    meta[:headers] ||= []
    meta[:headers] << "Accept: application/octet-stream"
    meta[:headers] << "Authorization: Bearer #{@github_token}"
    super("https://api.github.com/repos/#{@owner}/#{@repo}/releases/assets/#{asset_id}", name, version, **meta)
  end

  def parse_url_pattern
    url_pattern = %r{https://github\.com/([^/]+)/([^/]+)/releases/download/([^/]+)/(\S+)}
    raise CurlDownloadStrategyError, "Invalid url pattern: #{@url}" unless @url =~ url_pattern

    _, @owner, @repo, @tag, @filename = *@url.match(url_pattern)
  end

  private

  def asset_id
    @asset_id ||= begin
      assets = fetch_release["assets"] || []
      asset = assets.find { |a| a["name"] == @filename }
      raise CurlDownloadStrategyError, "Release #{@tag} of #{@owner}/#{@repo} has no asset #{@filename}" if asset.nil?

      asset.fetch("id")
    end
  end

  # A token that cannot see the private repository gets a 404, and
  # GitHub::API::HTTPNotFoundError carries no message, so brew would print only
  # the exception class. Translate it into the strategy's own error type, which
  # Downloadable#fetch renders with its text.
  def fetch_release
    GitHub.get_release(@owner, @repo, @tag)
  rescue GitHub::API::Error => e
    raise CurlDownloadStrategyError, <<~MSG
      Could not read release #{@tag} of #{@owner}/#{@repo} (#{e.class}).
      Either the release does not exist, or HOMEBREW_GITHUB_API_TOKEN does not
      name a GitHub token with read access to that private repository. Check:

        gh api repos/#{@owner}/#{@repo}/releases/tags/#{@tag} >/dev/null
    MSG
  end
end
