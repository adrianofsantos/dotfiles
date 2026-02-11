#!/bin/bash
# Installs a gitleaks pre-commit hook in the dotfiles repo
# Uses gitleaks v8.19+ syntax (git --pre-commit)
set -euo pipefail

DOTFILES_DIR="${1:-.}"
HOOK_PATH="${DOTFILES_DIR}/.git/hooks/pre-commit"

if [ ! -d "${DOTFILES_DIR}/.git" ]; then
  echo "Error: ${DOTFILES_DIR} is not a git repository."
  exit 1
fi

if ! command -v gitleaks &>/dev/null; then
  echo "Error: gitleaks not found. Install via: nix profile install nixpkgs#gitleaks"
  exit 1
fi

if [ -f "${HOOK_PATH}" ]; then
  echo "Pre-commit hook already exists at ${HOOK_PATH}"
  echo "Content:"
  cat "${HOOK_PATH}"
  echo ""
  read -t 30 -p "Overwrite? (y/N): " CONFIRM || CONFIRM="n"
  if [[ ! "${CONFIRM}" =~ ^[yY]$ ]]; then
    echo "Aborted."
    exit 0
  fi
fi

cat > "${HOOK_PATH}" << 'HOOK'
#!/bin/bash
# Gitleaks pre-commit hook — blocks commits containing secrets
echo "Running gitleaks pre-commit scan..."

if ! command -v gitleaks &>/dev/null; then
  echo "gitleaks not installed. Skipping check."
  echo "  Install: nix profile install nixpkgs#gitleaks"
  exit 0
fi

gitleaks git --pre-commit -v .
EXIT_CODE=$?

if [ ${EXIT_CODE} -ne 0 ]; then
  echo ""
  echo "Secrets detected in staged changes. Commit blocked."
  echo "   Review the output above and remove sensitive data."
  echo "   Bypass (not recommended): git commit --no-verify"
  exit 1
fi

echo "No secrets found."
HOOK

chmod +x "${HOOK_PATH}"
echo "Pre-commit hook installed at ${HOOK_PATH}"
