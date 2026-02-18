# git-clean-gone

A Rust CLI to remove local Git branches marked as `[gone]`.

## Features

- Detects branches with `[gone]`
- Skips the current branch
- Asks confirmation before deleting
- Prints a summary of deleted, skipped, and failed branches

## Installation

### Windows
Download the installer from the GitHub Releases page.

### macOS / Linux
Install with Homebrew after the tap is published:

```bash
brew install eldertorres/tap/git-clean-gone
```

### Rust users

```bash
cargo install git-clean-gone
```

## Release process

This repo includes a multi-platform release workflow in `.github/workflows/release.yml`.

