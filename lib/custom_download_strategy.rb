# typed: false
# frozen_string_literal: true

# Canonical source for getbrink/homebrew-tap:lib/custom_download_strategy.rb.
# The release workflow syncs this file into the tap; edit it here, never there.

require "download_strategy"
require "base64"

# Resolves a release asset through the Brink distribution broker
# (dl.getbrink.dev), authenticated with the partner's Brink access token — no
# separate GitHub credential. Reads HOMEBREW_BRINK_TOKEN specifically: brew's
# superenv strips arbitrary environment variables from formula/strategy code,
# passing through only HOMEBREW_*-prefixed ones, so the same token exported
# as $BRINK_TOKEN for pip/docker needs a second export under this name for
# brew. The broker resolves the tag/filename to the private
# getbrink/brink-releases asset server-side; GoReleaser writes the broker URL
# directly into the formula, so no asset-id lookup is needed here (unlike a
# raw GitHub fetch).
class BrinkBrokerDownloadStrategy < CurlDownloadStrategy
  def initialize(url, name, version, **meta)
    @brink_token = ENV.fetch("HOMEBREW_BRINK_TOKEN", nil)
    if @brink_token.nil? || @brink_token.empty?
      raise CurlDownloadStrategyError, <<~MSG
        brink release artifacts are served through the Brink distribution
        broker. Set HOMEBREW_BRINK_TOKEN to your Brink access token (the same
        one used for pip/docker) and retry:

          export HOMEBREW_BRINK_TOKEN=$BRINK_TOKEN
          brew install getbrink/tap/brink
      MSG
    end
    meta[:headers] ||= []
    meta[:headers] << "Authorization: Basic #{Base64.strict_encode64("#{@brink_token}:x")}"
    super(url, name, version, **meta)
  end
end
