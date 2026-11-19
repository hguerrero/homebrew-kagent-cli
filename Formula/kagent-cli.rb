class KagentCli < Formula
  desc "CLI for kagent, the Kubernetes native framework for building AI agents"
  homepage "https://kagent.dev"
  # Default (macOS Apple silicon) source; the blocks below override it per platform.
  url "https://github.com/kagent-dev/kagent/releases/download/v1.0.1/kagent-darwin-arm64"
  sha256 "3df94240b78feac0af6ae1b8fe5c452a68daa72ed41ef0c500015ed03ca9e375"
  license "Apache-2.0"

  livecheck do
    url :stable
    strategy :github_latest
  end

  on_macos do
    on_intel do
      url "https://github.com/kagent-dev/kagent/releases/download/v1.0.1/kagent-darwin-amd64"
      sha256 "f0c4650d4b0fb485ef9146bde94027b0170084da848277651f3f956787622c95"
    end
  end

  on_linux do
    on_intel do
      url "https://github.com/kagent-dev/kagent/releases/download/v1.0.1/kagent-linux-amd64"
      sha256 "f188182aaf445e5707ab8d3458f394fa30f875cc1786ec4f12a30b9fa0a8d77f"
    end
    on_arm do
      url "https://github.com/kagent-dev/kagent/releases/download/v1.0.1/kagent-linux-arm64"
      sha256 "a6ec9809094cdab0f3de6f662309f6accfa645cb8d5eec1551469689c73589e5"
    end
  end

  # Installs the same `kagent` binary as the homebrew/core formula (built from source).
  conflicts_with "kagent", because: "both install a `kagent` binary"

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
      Installing kagent into a cluster also requires `kubectl` and `helm` (v3).
    EOS
  end

  test do
    assert_match version.to_s, shell_output("#{bin}/kagent version")
  end
end
