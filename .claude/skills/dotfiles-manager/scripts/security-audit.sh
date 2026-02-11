#!/bin/bash
# Security audit script for dotfiles repository
# Runs gitleaks + additional dotfiles-specific checks
# Uses gitleaks v8.19+ syntax (dir/git commands)
set -uo pipefail

DOTFILES_DIR="${1:-.}"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

echo "=== Dotfiles Security Audit ==="
echo "Target: ${DOTFILES_DIR}"
echo ""

ISSUES=0

# 1. Gitleaks — current files
echo "--- [1/5] Gitleaks: scanning working tree ---"
if command -v gitleaks &>/dev/null; then
  if ! gitleaks dir -v "${DOTFILES_DIR}" 2>&1; then
    ISSUES=$((ISSUES + 1))
  else
    echo "✓ No secrets in working tree"
  fi
else
  echo "⚠ gitleaks not found. Install via: nix profile install nixpkgs#gitleaks"
  ISSUES=$((ISSUES + 1))
fi
echo ""

# 2. Gitleaks — full git history
echo "--- [2/5] Gitleaks: scanning git history ---"
if command -v gitleaks &>/dev/null; then
  if [ -d "${DOTFILES_DIR}/.git" ]; then
    if ! gitleaks git -v --log-opts="--all" "${DOTFILES_DIR}" 2>&1; then
      ISSUES=$((ISSUES + 1))
      echo "⚠ Secrets found in git history! See references/security.md for remediation."
    else
      echo "✓ No secrets in git history"
    fi
  else
    echo "⚠ Not a git repository, skipping history scan."
  fi
fi
echo ""

# 3. SSH private keys
echo "--- [3/5] Checking for SSH private keys ---"
PRIVATE_KEYS=$(find "${DOTFILES_DIR}" -name "id_*" -not -name "*.pub" -not -path "*/.git/*" 2>/dev/null || true)
if [ -n "${PRIVATE_KEYS}" ]; then
  echo "⚠ SSH private keys found:"
  echo "${PRIVATE_KEYS}"
  ISSUES=$((ISSUES + 1))
else
  echo "✓ No SSH private keys"
fi
echo ""

# 4. .env files
echo "--- [4/5] Checking for .env files ---"
ENV_FILES=$(find "${DOTFILES_DIR}" -not -path "*/.git/*" \( -name "*.env" -o -name ".env" -o -name ".env.*" \) -not -name ".envrc" 2>/dev/null || true)
if [ -n "${ENV_FILES}" ]; then
  echo "⚠ .env files found:"
  echo "${ENV_FILES}"
  ISSUES=$((ISSUES + 1))
else
  echo "✓ No .env files"
fi
echo ""

# 5. .gitignore coverage
echo "--- [5/5] Checking .gitignore coverage ---"
GITIGNORE="${DOTFILES_DIR}/.gitignore"
MISSING_PATTERNS=()
RECOMMENDED_PATTERNS=("*.pem" "*.key" ".env" "id_rsa" "id_ed25519" "*.p12" "*.pfx")

if [ -f "${GITIGNORE}" ]; then
  for pattern in "${RECOMMENDED_PATTERNS[@]}"; do
    if ! grep -qF "${pattern}" "${GITIGNORE}" 2>/dev/null; then
      MISSING_PATTERNS+=("${pattern}")
    fi
  done
  if [ ${#MISSING_PATTERNS[@]} -gt 0 ]; then
    echo "⚠ Missing recommended .gitignore patterns:"
    printf '  - %s\n' "${MISSING_PATTERNS[@]}"
    ISSUES=$((ISSUES + 1))
  else
    echo "✓ .gitignore covers recommended patterns"
  fi
else
  echo "⚠ No .gitignore found"
  ISSUES=$((ISSUES + 1))
fi
echo ""

# Summary
echo "=== Audit Complete ==="
if [ ${ISSUES} -eq 0 ]; then
  echo "✓ All checks passed. No issues found."
else
  echo "⚠ ${ISSUES} issue(s) found. Review output above."
fi
exit ${ISSUES}
