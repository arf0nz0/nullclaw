# BUILD-ARFONZO.md

Build and deploy instructions for the `arfonzo` nullclaw branch.

## Prerequisites

- **Zig 0.16.0** (`zig version` to verify)
- **Source:** `~/src/nullclaw` on the `arfonzo` branch
- **Platform:** aarch64 (Raspberry Pi 5), Debian 12 (bookworm)

## Build

```bash
cd ~/src/nullclaw && ./scripts/build-arfonzo.sh
```

The script handles:
- Version string: `arfonzo-<short-commit-hash>`
- Build flags: `-Dchannels=all -Dengines=base,sqlite -Doptimize=ReleaseFast`
- Reports binary path on completion

**Takes ~5+ minutes on Pi 5.** Run in background if you need the terminal:

```bash
nohup ./scripts/build-arfonzo.sh > /tmp/build.log 2>&1 &
```

### Binary location

```
zig-out/bin/nullclaw
```

## Deploy

Deploy is **manual** -- the build script does not copy the binary.

```bash
cp zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin
```

### Binary layout in `~/.local/bin/`

| File | Description |
|------|-------------|
| `nullclaw` | Symlink -- points to the active binary |
| `nullclaw-linux-aarch64-arfonzo.bin` | Custom arfonzo build (reports `arfonzo-<commit>`) |
| `nullclaw-linux-aarch64.bin` | Original release v2026.5.29 (4.4 MB), fallback |

### Switching binaries

```bash
# Use custom build
cd ~/.local/bin && ln -sf nullclaw-linux-aarch64-arfonzo.bin nullclaw

# Revert to upstream release
cd ~/.local/bin && ln -sf nullclaw-linux-aarch64.bin nullclaw
```

Takes effect on next gateway restart.

## Verify

```bash
nullclaw --version
# Should print: nullclaw arfonzo-<commit-hash>
```

## Build Constraints

- **Pi 5:** The build script uses default parallelism. If overheating occurs,
  build manually with reduced load.
- **Single source of truth:** Always use `./scripts/build-arfonzo.sh` for
  builds. Do not run `zig build` directly with ad-hoc flags.

## Upstream Sync Before Build

If syncing upstream changes before building:

```bash
# 1. Sync main with upstream
git checkout main && git fetch upstream && git merge upstream/main && git push origin main

# 2. Merge into arfonzo
git checkout arfonzo && git merge main

# 3. Resolve conflicts (likely in config_types.zig where SubagentConfig lives)
# 4. Commit and push
git push origin arfonzo

# 5. Build and deploy
./scripts/build-arfonzo.sh
cp zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin
```

## GitHub Remotes

| Remote | URL | Purpose |
|--------|-----|---------|
| `origin` | `git@github.com:arf0nz0/nullclaw.git` | Our fork (push target) |
| `upstream` | `https://github.com/nullclaw/nullclaw.git` | Official repo (pull updates) |

## Rollback

If the custom build is broken:

```bash
cd ~/.local/bin && ln -sf nullclaw-linux-aarch64.bin nullclaw
# Restart gateway
```
