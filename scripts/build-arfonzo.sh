#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

VERSION="arfonzo-$(git rev-parse --short HEAD)"

echo "Building nullclaw $VERSION..."
zig build \
  -Dchannels=all \
  -Dengines=base,sqlite \
  -Doptimize=ReleaseFast \
  -Dversion="$VERSION"

echo "Build complete."
echo ""
echo "Binary: $(pwd)/zig-out/bin/nullclaw"
echo "Copy to your install path manually."
