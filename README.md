# homebrew-kagent-cli

Homebrew tap for the [kagent](https://kagent.dev) CLI.

```sh
brew install hguerrero/kagent-cli/kagent-cli
# or
brew tap hguerrero/kagent-cli
brew install kagent-cli
```

Homebrew requires explicit trust for third-party taps. If `brew install` asks
for it, trust just this formula:

```sh
brew trust --formula hguerrero/kagent-cli/kagent-cli
```

Verify:

```sh
kagent version
```

The CLI should match the kagent version deployed in your cluster. Installing
kagent into a cluster also needs `kubectl` and `helm` (v3). See the
[installation guide](https://kagent.dev/docs/kagent/latest/setup/installation/).

## Why a separate formula

`homebrew/core` already ships a `kagent` formula that builds the CLI from
source with Go. This tap installs the prebuilt binaries that upstream attaches
to each release, so there is no Go toolchain and no compile step. Both install
a `kagent` binary, so the formulae conflict. Uninstall one before installing
the other.

## Supported platforms

The formula installs the binaries attached to each
[GitHub release](https://github.com/kagent-dev/kagent/releases):

| Platform              | Release asset          |
| --------------------- | ---------------------- |
| macOS (Apple silicon) | `kagent-darwin-arm64`  |
| macOS (Intel)         | `kagent-darwin-amd64`  |
| Linux x86_64          | `kagent-linux-amd64`   |
| Linux arm64           | `kagent-linux-arm64`   |

## Why a formula and not a cask

The release assets are bare CLI binaries, not `.app`, `.dmg` or `.pkg` bundles,
so a formula is the right fit and also covers Linux (Linuxbrew).

## Updating

`.github/workflows/bump.yml` checks every six hours for a new stable release and
opens a PR. The PR runs `brew test-bot` (`.github/workflows/tests.yml`), which
audits the formula and builds a bottle. For those checks to run on a
bot-created PR, add a `BUMP_TOKEN` repository secret (a PAT); PRs opened with
the default `GITHUB_TOKEN` do not trigger workflows.

To bump by hand:

```sh
scripts/bump.sh v1.0.1
```

To test a change locally before pushing:

```sh
brew install --build-from-source hguerrero/kagent-cli/kagent-cli
brew test kagent-cli
brew audit --strict hguerrero/kagent-cli/kagent-cli
```

## Publishing

Review each bump PR and wait for its checks to pass. Then publish its bottles
with `brew pr-pull` (preferably with the reviewed commit SHA):

```sh
brew pr-pull --tap=hguerrero/kagent-cli --head-sha=<sha> <PR number>
```

or run the **brew pr-pull** workflow from the Actions tab with the PR number
and, optionally, the expected head SHA.
