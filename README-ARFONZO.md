# README-ARFONZO.md

Customisations in arfonzo's nullclaw branch (`arfonzo`), documented for reference.
This branch tracks upstream `main` and merges cleanly. All customisations below
are the diff between `main` and `arfonzo`.

## Branch Info

- **Fork:** https://github.com/arf0nz0/nullclaw
- **Branch:** `arfonzo`
- **Base:** `main` (clean mirror of upstream)
- **Platform:** aarch64 (Raspberry Pi 5), Debian 12 (bookworm)
\n---\n\n## 1. Configurable Subagent Settings\n\n**Commit:** `5fbd5a96` -- feat: configurable subagent iteration limit\n\nMoves `SubagentConfig` from `subagent.zig` to `config_types.zig` and makes it\nconfigurable via `config.json`.\n\n### Config: `subagent`\n\n```json\n\\n---\n\n## 2. Build Script\n\n**Commit:** `debcf71b` -- feat: add build-arfonzo.sh helper script\n\nCustom build script with git-based version string (`arfonzo-<commit>`).\n\n### Usage\n\n```bash\ncd ~/src/nullclaw && ./scripts/build-arfonzo.sh\n```\n\n### Build Flags\n\n- `-Dchannels=all`\n- `-Dengines=base,sqlite`\n- `-Doptimize=ReleaseFast`\n- `-Dversion=\\n---\n\n## 3. Subagent Extra Tools & MCP Support\n\n**Commit:** `010789b2` -- feat(subagent): add extra_tools_enabled, extra_native_tools, and mcp_servers config\n\nAllows subagents to access additional native tools and MCP servers beyond the\nrestricted default set (shell, file I/O, git, http).\n\n### Config: `subagent`\n\n```json\n\
### Available Extra Native Tools

When `extra_tools_enabled` is true, subagents can use:

- `image_info`, `calculator`, `sqlite_query`, `anonymize_text`
- `memory_store`, `memory_recall`, `memory_list`, `memory_forget`
- `delegate`, `schedule`, `spawn`
- `pushover` (HTTP-gated)
- `web_search`, `web_fetch` (HTTP-gated)
- `browser` (if `browser_enabled`)
- `screenshot` (if `screenshot_enabled`)
- MCP tools from allowlisted servers

### Files Changed

- `src/config_types.zig` -- added extra fields to `SubagentConfig`
- `src/config_parse.zig` -- parsing for new fields
- `src/subagent.zig` -- `TaskRunRequest` and `SubagentManager` gain extra tool fields
- `src/subagent_runner.zig` -- threads to `subagentTools()`, MCP allowlist filtering
- `src/tools/root.zig` -- `subagentTools()` opts struct gains all extra tool fields + registrations
- `config.example.json` -- updated example with new fields

---

## 4. Migration Renamed Conflicts Tracking

**Commit:** `ec2edda6` -- Add renamed_conflicts tracking to migration stats

Adds `renamed_conflicts` counter to openclaw migration stats.

### Files Changed

- `src/migration.zig` -- added `renamed_conflicts` count, dry-run simulation
- `src/main.zig` -- updated migration output to show renamed count

---

## 5. GLM Model Family Context Window

**Commit:** `b306af30` -- feat: add GLM model family to MODEL_WINDOWS

Adds GLM model entries to context window table. All `glm-*` models report
200k token context window.

### Files Changed

- `src/agent/context_tokens.zig` -- GLM entries in `MODEL_WINDOWS` + prefix matcher
\n---\n\n## Upstream Sync Workflow\n\nKeep `main` as a clean mirror of upstream. Never merge upstream directly into\n`arfonzo`.\n\n```\nupstream/main -> origin/main -> arfonzo\n```\n\n1. `git checkout main`\n2. `git fetch upstream`\n3. `git merge upstream/main`\n4. `git push origin main`\n5. `git checkout arfonzo`\n6. `git merge main`\n7. Resolve conflicts (likely in `config_types.zig`)\n8. `git push origin arfonzo`\n9. Rebuild: `./scripts/build-arfonzo.sh`\n10. Deploy: `cp zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin`\n\n---\n\n## Deploy\n\nBinary built to `zig-out/bin/nullclaw`. Deploy is manual:\n\n```bash\ncp ~/src/nullclaw/zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin\n```\n\nTakes effect on next gateway restart (manual).\n\n### Binary Layout (`~/.local/bin/`)\n\n- `nullclaw` -> symlink -> `nullclaw-linux-aarch64-arfonzo.bin` (custom build)\n- `nullclaw-linux-aarch64-arfonzo.bin` -- arfonzo build, reports `nullclaw arfonzo-<commit>`\n- `nullclaw-linux-aarch64.bin` -- original release, preserved as fallback\n- Revert: `ln -sf nullclaw-linux-aarch64.bin nullclaw`\n- Restore: `ln -sf nullclaw-linux-aarch64-arfonzo.bin nullclaw`\n