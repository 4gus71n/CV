#!/usr/bin/env bash
#
# deploy.sh — Render the CV with RenderCV and publish to GitHub.
#
# Usage:
#   ./deploy.sh                       # render locally, commit + push, verify live
#   ./deploy.sh "My commit message"   # same, with a custom commit message
#   ./deploy.sh --check               # only render locally, don't push
#
# Requirements:
#   - git (with push access to origin)
#   - Python 3.12+ with RenderCV:  pip install "rendercv[full]"
#
# The single source of truth is rendercv.yaml. On push to main, the GitHub
# Action (.github/workflows/render-cv.yml) re-renders the CV and deploys it to
# GitHub Pages automatically — so this script only needs to commit + push. It
# also renders locally first so broken YAML/content fail before they ship.

set -euo pipefail

REPO_URL="https://4gus71n.github.io/CV/CV.html"
BRANCH="$(git symbolic-ref --short HEAD 2>/dev/null || echo main)"
YAML_INPUT="rendercv.yaml"
HTML_OUT="CV.html"
MD_OUT="CV.md"
PDF_OUT="CV.pdf"

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
info()  { printf "\033[1;34m==>\033[0m %s\n" "$*"; }
ok()    { printf "\033[1;32m==>\033[0m %s\n" "$*"; }
warn()  { printf "\033[1;33m==>\033[0m %s\n" "$*"; }
fail()  { printf "\033[1;31m==>\033[0m %s\n" "$*" >&2; exit 1; }

RENDERCV_BIN="${RENDERCV_BIN:-rendercv}"

find_rendercv() {
  if command -v "$RENDERCV_BIN" >/dev/null 2>&1; then
    return
  fi
  fail "RenderCV not found. Install it with: pip install \"rendercv[full]\", or set RENDERCV_BIN=/path/to/rendercv"
}

run_render() {
  if command -v "$RENDERCV_BIN" >/dev/null 2>&1; then
    "$RENDERCV_BIN" render "$YAML_INPUT" >/dev/null
  else
    python3 -m rendercv render "$YAML_INPUT" >/dev/null
  fi
}

# ---------------------------------------------------------------------------
# 1. Sanity checks
# ---------------------------------------------------------------------------
[ -d ".git" ] || fail "Not a git repository. Run this from the CV repo root."
[ -f "$YAML_INPUT" ] || fail "rendercv.yaml not found in the repo root."

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
# 2. Local render (validate before deploy)
# ---------------------------------------------------------------------------
find_rendercv

info "Rendering CV with RenderCV..."
run_render

info "Copying generated files to repo root..."
cp rendercv_output/agustin_tomas_larghi_CV.html "$HTML_OUT"
cp rendercv_output/agustin_tomas_larghi_CV.md "$MD_OUT"
cp rendercv_output/agustin_tomas_larghi_CV.pdf "$PDF_OUT"
rm -rf rendercv_output

if [ "$CHECK_ONLY" = true ]; then
  ok "Render succeeded (CV.html / CV.md / CV.pdf updated). Nothing was pushed."
  exit 0
fi

# ---------------------------------------------------------------------------
# 3. Commit + push
# ---------------------------------------------------------------------------
if git diff --quiet && git diff --cached --quiet && [ -z "$(git ls-files --others --exclude-standard)" ]; then
  warn "No changes to commit — skipping git push (site already up to date)."
  exit 0
fi

info "Committing changes..."
git add -A
git commit -m "$MESSAGE"

info "Pushing to origin/$BRANCH (GitHub Action will deploy to Pages)..."
git push origin "$BRANCH"

# ---------------------------------------------------------------------------
# 4. Verify the live deployment
# ---------------------------------------------------------------------------
info "Waiting for GitHub Actions to render and deploy..."
sleep 45

for attempt in 1 2 3 4 5 6 7 8 9 10; do
  if curl -fsS -o /dev/null --max-time 15 "$REPO_URL" 2>/dev/null; then
    ok "Deployed successfully: $REPO_URL"
    exit 0
  fi
  info "Still building… (attempt $attempt/10, waiting 20s)"
  sleep 20
done

warn "Push succeeded but the live site hasn't come up yet."
warn "Check the Actions tab at https://github.com/$(git remote get-url origin | sed -E 's#.*github.com[:/](.*)\.git#\1#')/actions"
exit 1
