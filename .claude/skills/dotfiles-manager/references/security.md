# Security Audit Reference

## Tools

### gitleaks (already in flake.nix)
Scans git repos for hardcoded secrets (API keys, tokens, passwords, private keys).

Note: Since v8.19.0, `detect` and `protect` are deprecated. Use `git`, `dir`, and `stdin` commands instead.

### Quick Commands

```bash
# Scan current files (working tree, ignores git history)
gitleaks dir -v .

# Scan git history (IMPORTANT — catches deleted secrets)
gitleaks git -v .

# Scan entire git history including all branches
gitleaks git -v --log-opts="--all" .

# Scan specific commit range
gitleaks git -v --log-opts="commitA..commitB" .

# Generate JSON report
gitleaks git -v --report-path gitleaks-report.json --report-format json .

# Pre-commit: scan staged changes only
gitleaks git --pre-commit -v .
```

## Pre-commit Hook Setup

### Option A: Direct git hook (simpler)
```bash
# Install hook
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
echo "Running gitleaks pre-commit check..."
gitleaks git --pre-commit -v .
EXIT_CODE=$?
if [ ${EXIT_CODE} -ne 0 ]; then
  echo "gitleaks found secrets in staged changes. Commit blocked."
  echo "Fix the issues or use 'git commit --no-verify' to bypass (not recommended)."
  exit 1
fi
EOF
chmod +x .git/hooks/pre-commit
```

### Option B: Using pre-commit framework
```yaml
# .pre-commit-config.yaml
repos:
  - repo: https://github.com/gitleaks/gitleaks
    rev: v8.21.2
    hooks:
      - id: gitleaks
```

Then: `pre-commit install`

## What gitleaks Detects

- AWS access keys and secret keys
- SSH private keys
- GCP service account keys
- GitHub/GitLab tokens
- Generic API keys and passwords
- Slack tokens
- Database connection strings
- JWT tokens

## Custom Rules (.gitleaks.toml)

For reducing false positives in dotfiles repos:
```toml
[allowlist]
description = "Dotfiles-specific allowlist"
paths = [
  '''.*\.lock$''',
  '''.*lazy-lock\.json$''',
  '''.*\.theme$''',
]
```

## If Secrets Are Found in History

1. **Don't panic.** Rotate the compromised credential first.
2. Use `git filter-repo` (NOT `git filter-branch`) to remove from history:
   ```bash
   pip install git-filter-repo
   git filter-repo --invert-paths --path <file-with-secret>
   ```
3. Force push (after confirming with team if shared repo):
   ```bash
   git push --force-with-lease
   ```
4. Add the pattern to `.gitignore` and `.gitleaks.toml` allowlist if it was a false positive.

## Additional Checks for Dotfiles

Beyond gitleaks, verify:
- No SSH private keys in repo (`find . -name "id_*" -not -name "*.pub"`)
- No `.env` files committed (`git log --all --diff-filter=A -- "*.env"`)
- No GPG private keys
- `.gitignore` covers: `*.pem`, `*.key`, `.env*`, `id_rsa`, `id_ed25519`, `*.p12`
