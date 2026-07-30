# AGENTS.md - nullclaw arfonzo branch rules

Gitignored. Rules for working on arfonzo branch.

## Build

ALWAYS build with the custom script before committing:

    cd ~/src/nullclaw && ./scripts/build-arfonzo.sh

Never commit broken builds. Fix errors first, rebuild, commit only when green.

## Documentation

ALWAYS update README-ARFONZO.md when adding or changing customisations.
Keep it in sync with the actual diff between main and arfonzo.

## Upstream Sync

Never merge upstream directly into arfonzo. Flow:

    upstream/main -> origin/main -> arfonzo

1. git checkout main && git fetch upstream && git merge upstream/main && git push origin main
2. git checkout arfonzo && git merge main
3. Resolve conflicts (likely in config_types.zig)
4. git push origin arfonzo
5. Rebuild and deploy

## Deploy

Never deploy yourself, notify the user to manually copy/deploy.

Takes effect on next gateway restart (human restarts manually).
