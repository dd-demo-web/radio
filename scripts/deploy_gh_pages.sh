#!/usr/bin/env bash
# Builda la web app Flutter e la pubblica sul branch gh-pages di origin.
#
# Uso:
#   ./scripts/deploy_gh_pages.sh [base-href]
#
# Esempio:
#   ./scripts/deploy_gh_pages.sh /radio/
#
# Se omesso, base-href di default è "/radio/" (deve corrispondere al nome
# del repository GitHub per Project Pages, es. dd-demo-web/radio -> /radio/).

set -euo pipefail

BASE_HREF="${1:-/radio/}"
REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORKTREE_DIR="$(mktemp -d /tmp/radio-ghpages.XXXXXX)"

cd "$REPO_ROOT"

echo "==> Build Flutter web (release, base-href=${BASE_HREF})"
flutter build web --release --base-href "$BASE_HREF"

echo "==> Preparazione worktree temporaneo per gh-pages"
git fetch origin gh-pages --quiet || true

if git show-ref --verify --quiet refs/remotes/origin/gh-pages; then
  git worktree add --detach "$WORKTREE_DIR" origin/gh-pages
  (cd "$WORKTREE_DIR" && git checkout -B gh-pages)
else
  git worktree add --detach "$WORKTREE_DIR"
  (cd "$WORKTREE_DIR" && git checkout --orphan gh-pages && git rm -rf . >/dev/null)
fi

echo "==> Sincronizzazione contenuti build/web"
find "$WORKTREE_DIR" -mindepth 1 -maxdepth 1 ! -name '.git' -exec rm -rf {} +
cp -R "$REPO_ROOT/build/web/." "$WORKTREE_DIR/"
touch "$WORKTREE_DIR/.nojekyll"

cd "$WORKTREE_DIR"
git add -A
if git diff --cached --quiet; then
  echo "==> Nessuna modifica da pubblicare."
else
  git commit -m "Deploy web build to GitHub Pages"
  git push origin gh-pages
  echo "==> Deploy completato."
fi

cd "$REPO_ROOT"
git worktree remove --force "$WORKTREE_DIR"
