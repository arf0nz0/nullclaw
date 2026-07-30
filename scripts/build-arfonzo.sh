#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

# Resolve zig binary: $ZIG env var → PATH → ~/.local/bin/zig
ZIG="${ZIG:-$(command -v zig 2>/dev/null)}"
if [ -z "$ZIG" ]; then
    ZIG="$HOME/.local/bin/zig"
fi
if [ ! -x "$ZIG" ]; then
    echo "ERROR: zig not found (tried PATH and $HOME/.local/bin/zig)" >&2
    exit 1
fi

VERSION="arfonzo-$(git rev-parse --short HEAD)"

echo "Building nullclaw $VERSION..."
"$ZIG" build \
  -Dchannels=all \
  -Dengines=base,sqlite \
  -Doptimize=ReleaseFast \
  -Dversion="$VERSION"

echo "Build complete."
echo ""
echo "Binary: $(pwd)/zig-out/bin/nullclaw"
echo "Copy to your install path manually."
