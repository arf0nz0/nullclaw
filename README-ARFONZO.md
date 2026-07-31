# README-ARFONZO.md

Customisations in arfonzo's nullclaw branch (arfonzo), documented for reference.
This branch tracks upstream main and merges cleanly. All customisations below
are the diff between main and arfonzo.

## Branch Info

- **Fork:** https://github.com/arf0nz0/nullclaw
- **Branch:** arfonzo
- **Base:** main (clean mirror of upstream)
- **Platform:** aarch64 (Raspberry Pi 5), Debian 12 (bookworm)

---

## 1. Configurable Subagent Settings

**Commit:** 5fbd5a96 -- feat: configurable subagent iteration limit

Moves SubagentConfig from subagent.zig to config_types.zig and makes it
configurable via config.json.

### Config: subagent

  "subagent": {
    "max_iterations": 100,
    "max_concurrent": 4
  }

### Files Changed

- src/config_types.zig -- SubagentConfig struct with configurable fields
- src/config_parse.zig -- parsing for subagent config section
- src/subagent.zig -- reads config instead of hardcoded defaults

---

## 2. Build Script

**Commit:** debcf71b -- feat: add build-arfonzo.sh helper script

Custom build script with git-based version string (arfonzo-commit).

### Usage

  cd ~/src/nullclaw && ./scripts/build-arfonzo.sh

### Build Flags

- -Dchannels=all
- -Dengines=base,sqlite
- -Doptimize=ReleaseFast
- -Dversion=arfonzo-git-commit-short

---

## 3. Subagent Extra Tools and MCP Support

**Commit:** 010789b2 -- feat(subagent): add extra_tools_enabled, extra_native_tools, and mcp_servers config

Allows subagents to access additional native tools and MCP servers beyond the
restricted default set (shell, file I/O, git, http).

### Config: subagent

  "subagent": {
    "max_iterations": 1000,
    "max_concurrent": 4,
    "extra_tools_enabled": true,
    "extra_native_tools": ["*"],
    "mcp_servers": ["lean-ctx"]
  }

### Available Extra Native Tools

When extra_tools_enabled is true, subagents can use:

- image_info, calculator, sqlite_query, anonymize_text
- memory_store, memory_recall, memory_list, memory_forget
- delegate, schedule, spawn
- pushover (HTTP-gated)
- web_search, web_fetch (HTTP-gated)
- browser (if browser_enabled)
- screenshot (if screenshot_enabled)
- MCP tools from allowlisted servers

### Files Changed

- src/config_types.zig -- added extra fields to SubagentConfig
- src/config_parse.zig -- parsing for new fields
- src/subagent.zig -- TaskRunRequest and SubagentManager gain extra tool fields
- src/subagent_runner.zig -- threads to subagentTools(), MCP allowlist filtering
- src/tools/root.zig -- subagentTools() opts struct gains all extra tool fields + registrations
- config.example.json -- updated example with new fields

---

## 4. Migration Renamed Conflicts Tracking

**Commit:** ec2edda6 -- Add renamed_conflicts tracking to migration stats

Adds renamed_conflicts counter to openclaw migration stats.

### Files Changed

- src/migration.zig -- added renamed_conflicts count, dry-run simulation
- src/main.zig -- updated migration output to show renamed count

---

## 5. GLM Model Family Context Windows

**Commit:** b306af30 -- feat: add GLM model family to MODEL_WINDOWS

Adds GLM model entries to context window table with correct per-model values.

### Context Windows

- glm-5.2: 1,048,576 (1M)
- glm-5.1: 200,000
- glm-5: 200,000
- glm-5-turbo: 200,000
- glm-4.7: 200,000
- glm-4.6: 200,000
- glm-4.5: 128,000
- glm-4-32b-0414-128k: 128,000
- glm-* (fallback prefix match): 200,000

### Files Changed

- src/agent/context_tokens.zig -- GLM entries in MODEL_WINDOWS + prefix matcher

---

## 6. Per-Model Overrides for Reasoning Effort

**Commit:** 3919ef5e -- feat: add per-model overrides for reasoning effort config

Allows defining model-specific reasoning effort vocabularies and defaults in
config.json, instead of relying on hardcoded global defaults.

### Config: model_overrides

  "model_overrides": [
    {
      "model": "glm-5.2",
      "valid_reasoning_efforts": ["low", "medium", "high", "max"],
      "default_reasoning_effort": "high"
    }
  ]

### Fields

- model (string, required) -- model name to match (e.g. glm-5.2)
- valid_reasoning_efforts (array of strings, optional) -- restricts valid effort values for this model. When null, built-in defaults apply.
- default_reasoning_effort (string, optional) -- default effort applied when none is explicitly set.

### Files Changed

- src/config_types.zig -- new ModelOverride struct
- src/config.zig -- model_overrides config field
- src/config_parse.zig -- JSON parsing for model_overrides section
- src/agent/cli.zig -- CLI wiring
- src/agent/commands.zig -- command plumbing
- src/agent/root.zig -- applyModelOverrides() function + Agent field

---

## 7. Tool Call Format and Truncation Bug Fixes

**Commit:** 3e6c17bf -- fix(agent): prevent truncation and tag-eating in prose

Three confirmed bugs fixed:

### Bug 1: Message Truncation

**Root cause:** selectDisplayText() returned empty string when tool-call markup
was detected in parsed_text but no valid calls were parsed. This ate 1400+ bytes
when the model mentioned tool-call tags in explanatory prose.

**Fix:** Return response_text (full response) instead of empty string.

**File:** src/agent/root.zig -- selectDisplayText()

### Bug 2: Tag-Eating in Prose

**Root cause:** parseXmlToolCalls() discarded the full block when inner content
failed JSON parse. Tag markers and inner text were lost.

**Fix:** Preserve the full block including tag markers when inner content fails to
parse as a valid tool call.

**File:** src/agent/dispatcher.zig -- parseXmlToolCalls()

### Bug 3: Contradictory Tool Format Instructions

**Root cause:** Tool format instructions (XML tool_call format) were always
emitted in the system prompt, even for models using native function calling.
This created contradictory guidance.

**Fix:** Wrap tool format instructions in a native_tools_enabled conditional so
models using native function calling do not get XML format guidance.

**File:** src/agent/prompt.zig -- writeToolInstructionsSection()

---

## 8. Inline Injected Strings Override

**Commit:** (pending)

Replaces the separate `injected_strings.json` file with an inline `injected_strings`
section in `config.json`. Removes the need for a separate file and adds an `enabled`
boolean kill switch.

### Config: injected_strings

  "injected_strings": {
    "enabled": true,
    "reflection_prompt": "...",
    "empty_response_retry": "...",
    "force_follow_through": "...",
    "max_iterations": "...",
    "skip_tool_descriptions_native": true,
    "safety_section": "...",
    "channel_choices": "...",
    "scheduled_tasks_group": "..."
  }

### Fields

- enabled (bool, required) — master toggle. false disables all overrides, falling back to hardcoded defaults.
- reflection_prompt (string, optional) — injected after each tool batch to prompt analysis.
- empty_response_retry (string, optional) — injected when the model returns an empty response.
- force_follow_through (string, optional) — injected when the model promises action but doesn't call tools.
- max_iterations (string, optional) — injected when max tool iterations is reached.
- skip_tool_descriptions_native (bool, optional) — when true, skips tool name+description lines in the system prompt for providers using native function calling (saves ~1,376 tokens/session).
- safety_section (string, optional) — overrides the hardcoded safety/security section of the system prompt.
- channel_choices (string, optional) — overrides the channel choices formatting instructions.
- scheduled_tasks_group (string, optional) — overrides the scheduled tasks group instructions. `{gid}` placeholder is substituted at runtime.

### Files Changed

- src/config_types.zig -- new InjectedStringsConfig struct
- src/config.zig -- injected_strings field replaces injected_strings_override path
- src/config_parse.zig -- parses inline JSON section instead of file path
- src/agent/root.zig -- reads from config struct instead of loading file
- src/agent/injected_strings.zig -- InjectedStrings struct kept, load() function now unused (can be removed in future cleanup)
- config.example.json -- added example injected_strings section

---

## Upstream Sync Workflow

Keep main as a clean mirror of upstream. Never merge upstream directly into
arfonzo.

  upstream/main -> origin/main -> arfonzo

1. git checkout main
2. git fetch upstream
3. git merge upstream/main
4. git push origin main
5. git checkout arfonzo
6. git merge main
7. Resolve conflicts (likely in config_types.zig)
8. git push origin arfonzo
9. Rebuild: ./scripts/build-arfonzo.sh
10. Deploy: cp zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin

---

## Deploy

Binary built to zig-out/bin/nullclaw. Deploy is manual:

  cp ~/src/nullclaw/zig-out/bin/nullclaw ~/.local/bin/nullclaw-linux-aarch64-arfonzo.bin

Takes effect on next gateway restart (manual).

### Binary Layout (~/.local/bin/)

- nullclaw -> symlink -> nullclaw-linux-aarch64-arfonzo.bin (custom build)
- nullclaw-linux-aarch64-arfonzo.bin -- arfonzo build, reports nullclaw arfonzo-commit
- nullclaw-linux-aarch64.bin -- original release, preserved as fallback
- Revert: ln -sf nullclaw-linux-aarch64.bin nullclaw
- Restore: ln -sf nullclaw-linux-aarch64-arfonzo.bin nullclaw
