#!/bin/zsh
set -euo pipefail

ZIP="${1:-$HOME/Desktop/Zhilu_Yang_Research_Profile_Compact_20260731.zip}"
REPO="ada-zy2425/ada-zy2425.github.io"
WORK="$HOME/Desktop/zhilu_github_pages_$(date +%Y%m%d_%H%M%S)"
EXTRACT="$WORK/_extract"
SITE="$WORK/site"
CHECKOUT="$WORK/repo"

[[ -f "$ZIP" ]] || {
  echo "[FATAL] ZIP not found: $ZIP"
  exit 10
}

command -v gh >/dev/null 2>&1 || {
  echo "[FATAL] GitHub CLI is missing"
  echo "Run: brew install gh"
  exit 11
}

gh auth status >/dev/null 2>&1 || {
  echo "[FATAL] GitHub CLI is not logged in"
  echo "Run: gh auth login --web --git-protocol https"
  exit 12
}

LOGIN="$(gh api user --jq '.login')"
[[ "$LOGIN" == "ada-zy2425" ]] || {
  echo "[FATAL] GitHub CLI is logged in as: $LOGIN"
  echo "Expected account: ada-zy2425"
  echo "Run: gh auth logout --hostname github.com"
  echo "Then: gh auth login --web --git-protocol https"
  exit 13
}

mkdir -p "$EXTRACT" "$SITE"
ditto -x -k "$ZIP" "$EXTRACT"

INDEX="$(find "$EXTRACT" -type f -name index.html -print -quit)"
[[ -n "$INDEX" ]] || {
  echo "[FATAL] index.html not found inside ZIP"
  exit 20
}

ROOT="$(dirname "$INDEX")"
rsync -a --delete --exclude '.DS_Store' "$ROOT/" "$SITE/"
rm -rf "$EXTRACT"

[[ -f "$SITE/index.html" ]] || {
  echo "[FATAL] index.html is not at the site root"
  exit 21
}

open "$SITE/index.html"
echo "[LOCAL_PREVIEW_OPENED] $SITE/index.html"

if gh repo view "$REPO" >/dev/null 2>&1; then
  gh repo clone "$REPO" "$CHECKOUT"
  find "$CHECKOUT" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
  rsync -a --delete --exclude '.git' --exclude '.DS_Store' "$SITE/" "$CHECKOUT/"
  cd "$CHECKOUT"
  git config user.name "Zhilu Yang"
  git config user.email "yyang121013@gmail.com"
  git add -A
  if git diff --cached --quiet; then
    echo "[NO_CONTENT_CHANGE]"
  else
    git commit -m "Update academic research profile"
    git push origin HEAD:main
  fi
else
  cd "$SITE"
  git init -q
  git branch -M main
  git config user.name "Zhilu Yang"
  git config user.email "yyang121013@gmail.com"
  git add .
  git commit -m "Publish academic research profile"
  gh repo create "$REPO" \
    --public \
    --description "Academic research profile of Zhilu Yang" \
    --source=. \
    --remote=origin \
    --push
fi

if gh api "repos/$REPO/pages" >/dev/null 2>&1; then
  gh api \
    --method PUT \
    "repos/$REPO/pages" \
    -f 'source[branch]=main' \
    -f 'source[path]=/' \
    >/dev/null
else
  gh api \
    --method POST \
    "repos/$REPO/pages" \
    -f 'source[branch]=main' \
    -f 'source[path]=/' \
    >/dev/null
fi

echo "[PUSH_COMPLETE]"
echo "Repository: https://github.com/$REPO"
echo "Pages: https://ada-zy2425.github.io/"
echo "First publication can take several minutes."
open "https://github.com/$REPO/settings/pages"
