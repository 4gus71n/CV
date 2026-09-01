#!/usr/bin/env bash
#
# deploy.sh — Build, commit and publish the CV to GitHub Pages.
#
# Usage:
#   ./deploy.sh                       # build, commit + push, verify live
#   ./deploy.sh "My commit message"   # same, with a custom commit message
#   ./deploy.sh --check               # only validate the local build, don't push
#
# Requirements:
#   - git (with push access to origin)
#   - Ruby + Jekyll (the github-pages gem is recommended, see README.md)
#
# The site lives in this repo and is served by GitHub Pages from the `main`
# branch. This script builds the site locally (so broken templates/CSS fail
# before they ever reach production), commits all changes, pushes them, and
# then polls the live URL to confirm the deployment succeeded.

set -euo pipefail

REPO_URL="https://4gus71n.github.io/CV/CV.html"
BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m==>\033[0m %s\n" "$*"; }
fail()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; exit 1; }

# Locate a usable Ruby + Jekyll (honors Homebrew installs, user gems, rbenv/rvm).
find_jekyll() {
  if command -v jekyll >/dev/null 2>&1; then
    return
  fi
  for candidate in \
    "$HOME/.gem/ruby/3.4.0/bin" \
    "$HOME/.gem/ruby/3.3.0/bin" \
    "/opt/homebrew/bin" \
    "/opt/homebrew/opt/ruby/bin" \
    "/usr/local/opt/ruby/bin" \
    "/usr/local/bin"; do
    if [ -x "$candidate/jekyll" ]; then
      export PATH="$candidate:$PATH"
      return
    fi
  done
  fail "Jekyll not found. See README.md for setup instructions."
}

# ---------------------------------------------------------------------------
# 1. Sanity checks
# ---------------------------------------------------------------------------
[ -d ".git" ] || fail "Not a git repository. Run this from the CV repo root."

if ! git diff --cached --quiet 2>/dev/null; then
  fail "You have staged changes. Run 'git reset' first, then re-run this script."
fi

MESSAGE="${1:-Update CV}"
CHECK_ONLY=false
if [ "${1:-}" = "--check" ] || [ "${1:-}" = "-c" ]; then
  CHECK_ONLY=true
  MESSAGE=""
fi

# ---------------------------------------------------------------------------
# 2. Local build (validate before deploy)
# ---------------------------------------------------------------------------
find_jekyll

info "Building site with Jekyll..."
if ! jekyll build --baseurl "/$(basename "$PWD")" >/dev/null; then
  rm -rf _site
  fail "Local build failed. Fix the errors above before deploying."
fi

if [ "$CHECK_ONLY" = true ]; then
  ok "Build succeeded (checked into _site/). Nothing was pushed."
  exit 0
fi

# ---------------------------------------------------------------------------
# 3. Commit + push
# ---------------------------------------------------------------------------
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  warn "No changes to commit — skipping git push (site already up to date)."
  rm -rf _site
  exit 0
fi

rm -rf _site   # never commit build output

info "Committing changes..."
git add -A
git commit -m "$MESSAGE"

info "Pushing to origin/$BRANCH..."
git push origin "$BRANCH"

# ---------------------------------------------------------------------------
# 4. Verify the live deployment
# ---------------------------------------------------------------------------
info "Waiting for GitHub Pages to rebuild..."
sleep 20

for attempt in 1 2 3 4 5 6 7 8; do
  if curl -fsS -o /dev/null --max-time 15 "$REPO_URL" 2>/dev/null; then
    ok "Deployed successfully: $REPO_URL"
    rm -rf _site 2>/dev/null || true
    exit 0
  fi
  info "Still building… (attempt $attempt/8, waiting 10s)"
  sleep 10
done

warn "Push succeeded but the live site hasn't come up yet."
warn "Check the Actions/Pages tab at https://github.com/$(git remote get-url origin | sed -E 's#.*github.com[:/](.*)\.git#\1#')/actions"
exit 1
