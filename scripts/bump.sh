#!/usr/bin/env bash
# Rewrite Formula/kagent-cli.rb for a given kagent release.
# Usage: scripts/bump.sh [vX.Y.Z]   (defaults to the latest GitHub release)
set -euo pipefail

REPO="kagent-dev/kagent"
FORMULA="$(cd "$(dirname "$0")/.." && pwd)/Formula/kagent-cli.rb"

tag="${1:-$(gh release view --repo "${REPO}" --json tagName -q .tagName)}"
tag="v${tag#v}"
base="https://github.com/${REPO}/releases/download/${tag}"

sha_for() {
  # The .sha256 asset is "<hash>  core/bin/<name>"; keep only the hash.
  curl -fsSL "${base}/kagent-$1.sha256" | awk '{print $1}'
}

darwin_arm64="$(sha_for darwin-arm64)"
darwin_amd64="$(sha_for darwin-amd64)"
linux_amd64="$(sha_for linux-amd64)"
linux_arm64="$(sha_for linux-arm64)"

cat >"${FORMULA}" <<EOF
class KagentCli < Formula
  desc "CLI for kagent, the Kubernetes native framework for building AI agents"
  homepage "https://kagent.dev"
  # Default (macOS Apple silicon) source; the blocks below override it per platform.
  url "${base}/kagent-darwin-arm64"
  sha256 "${darwin_arm64}"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_intel do
      url "${base}/kagent-darwin-amd64"
      sha256 "${darwin_amd64}"
    end
  end

  on_linux do
    on_intel do
      url "${base}/kagent-linux-amd64"
      sha256 "${linux_amd64}"
    end
    on_arm do
      url "${base}/kagent-linux-arm64"
      sha256 "${linux_arm64}"
    end
  end

  # Installs the same \`kagent\` binary as the homebrew/core formula (built from source).
  conflicts_with "kagent", because: "both install a \`kagent\` binary"

  def install
    # The release asset is a bare, prebuilt binary named kagent-<os>-<arch>.
    binary = Dir["kagent-*"].first
    chmod 0755, binary
    bin.install binary => "kagent"

    generate_completions_from_executable(bin/"kagent", shell_parameter_format: :cobra)
  end

  def caveats
    <<~EOS
      The kagent CLI should match the kagent version deployed in your cluster.
      Installing kagent into a cluster also requires \`kubectl\` and \`helm\` (v3).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kagent version")
  end
end
EOF

echo "Formula updated to ${tag}"
