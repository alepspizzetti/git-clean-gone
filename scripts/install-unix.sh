#!/usr/bin/env sh
set -eu

REPO="eldertorres/git-clean-gone"
APP="git-clean-gone"
VERSION="${GIT_CLEAN_GONE_VERSION:-latest}"
INSTALL_DIR="${GIT_CLEAN_GONE_INSTALL_DIR:-$HOME/.local/bin}"
BASE_URL="https://github.com/$REPO/releases"

need_cmd() {
  if ! command -v "$1" >/dev/null 2>&1; then
    echo "error: required command not found: $1" >&2
    exit 1
  fi
}

case "$(uname -s)" in
  Darwin) os="apple-darwin" ;;
  Linux) os="unknown-linux-gnu" ;;
  *)
    echo "error: unsupported OS: $(uname -s)" >&2
    echo "supported: macOS and Linux x86_64" >&2
    exit 1
    ;;
esac

case "$(uname -m)" in
  x86_64|amd64) arch="x86_64" ;;
  arm64|aarch64)
    if [ "$os" = "apple-darwin" ]; then
      arch="aarch64"
    else
      echo "error: Linux arm64 release asset is not currently published" >&2
      exit 1
    fi
    ;;
  *)
    echo "error: unsupported CPU architecture: $(uname -m)" >&2
    exit 1
    ;;
esac

need_cmd tar
need_cmd mkdir
need_cmd mktemp

if command -v curl >/dev/null 2>&1; then
  download() { curl --fail --location --proto '=https' --tlsv1.2 --silent --show-error "$1" --output "$2"; }
elif command -v wget >/dev/null 2>&1; then
  download() { wget -qO "$2" "$1"; }
else
  echo "error: required command not found: curl or wget" >&2
  exit 1
fi

triple="$arch-$os"
asset="$APP-$triple.tar.xz"
if [ "$VERSION" = "latest" ]; then
  url="$BASE_URL/latest/download/$asset"
else
  url="$BASE_URL/download/$VERSION/$asset"
fi

tmpdir="$(mktemp -d)"
cleanup() { rm -rf "$tmpdir"; }
trap cleanup EXIT INT TERM

echo "Installing $APP from $url"
download "$url" "$tmpdir/$asset"
tar -xJf "$tmpdir/$asset" -C "$tmpdir"

mkdir -p "$INSTALL_DIR"
cp "$tmpdir/$APP-$triple/$APP" "$INSTALL_DIR/$APP"
chmod +x "$INSTALL_DIR/$APP"

echo "$APP installed to $INSTALL_DIR/$APP"
case ":$PATH:" in
  *":$INSTALL_DIR:"*) ;;
  *)
    echo "warning: $INSTALL_DIR is not in PATH"
    echo "add this to your shell profile: export PATH=\"$INSTALL_DIR:\$PATH\""
    ;;
esac
