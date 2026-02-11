---
name: dotfiles-manager
description: >
  Gerenciamento de dotfiles e configurações para macOS com nix-darwin flakes.
  Usa stow (migrando para home-manager). Suporta múltiplos hosts (Aang, Kyoshi).
  Use para: (1) Adicionar/remover pacotes no flake.nix, (2) Bootstrap de máquina nova,
  (3) Auditoria de segurança (gitleaks, secrets no histórico git),
  (4) Gerenciar dotfiles e symlinks, (5) Criar novo host no flake,
  (6) Migrar configs do stow para home-manager.
  Triggers: dotfiles, flake, nix-darwin, darwin-rebuild, stow, home-manager,
  pacote, package, bootstrap, segurança, security, gitleaks, secrets.
---

# Dotfiles Manager

Skill para gerenciar o repositório de dotfiles do Adriano — nix-darwin flakes, dotfiles via stow (migrando para home-manager), múltiplos hosts macOS.

Read [references/flake-structure.md](references/flake-structure.md) to understand the current repo layout, host hierarchy, and package layers.

## Workflow Decision Tree

1. **Adicionar/remover pacote?** → See "Package Management" below
2. **Configurar máquina nova?** → Read [references/bootstrap.md](references/bootstrap.md)
3. **Auditoria de segurança?** → See "Security" below
4. **Adicionar/editar dotfile?** → See "Dotfile Management" below
5. **Criar novo host?** → Read [references/bootstrap.md](references/bootstrap.md) § "Adding a New Host"
6. **Migrar para home-manager?** → Read [references/flake-structure.md](references/flake-structure.md) § "Home-Manager Migration Path"

## Package Management

Before modifying `flake.nix`, read [references/flake-structure.md](references/flake-structure.md) to understand the host hierarchy and package layers.

### Adding a Package

1. Determine package type:
   - CLI tool available in nixpkgs → `environment.systemPackages`
   - GUI app → `homebrew.casks`
   - CLI only in homebrew → `homebrew.brews`
   - Mac App Store → `homebrew.masApps` (run `mas search <name>` for ID)

2. Determine scope:
   - All machines → `commonConfiguration`
   - Personal machines → `personalConfiguration`
   - Single host → host-specific config (e.g. `kyoshiConfiguration`)

3. Edit `nix/flake.nix` accordingly.

4. Apply: `sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/`

### Removing a Package

Same logic in reverse. Note: `homebrew.onActivation.cleanup = "zap"` ensures removed casks are uninstalled on next rebuild.

## Security

Read [references/security.md](references/security.md) for full details on gitleaks commands and remediation.

### Quick Audit

Run the bundled audit script:
```bash
bash scripts/security-audit.sh /path/to/dotfiles
```

This runs 5 checks: gitleaks (working tree), gitleaks (git history), SSH key scan, .env file scan, .gitignore coverage.

### Pre-commit Hook

Install gitleaks pre-commit hook to block commits with secrets:
```bash
bash scripts/setup-precommit-hook.sh /path/to/dotfiles
```

## Dotfile Management

### Current State (stow)

Dotfiles live in top-level directories (zsh/, nvim/, alacritty/, etc.). `.stowrc` targets `~/.config`. The `config.sh` script runs `stow . -v` to create symlinks.

For zsh specifically, `.zshrc` is handled separately via `zsh/zsh-config.sh` (targets `$HOME` instead of `~/.config`).

### Adding a New Dotfile

1. Create directory matching the config structure: `mkdir -p <tool>/.config/<tool>/` (or just `<tool>/` if config goes under `~/.config/<tool>/`)
2. Place config file(s) inside
3. Run `stow . -v` from dotfiles root (or `./config.sh`)
4. Add to `.gitignore` any generated/cache files

### Migration to home-manager

Read [references/flake-structure.md](references/flake-structure.md) § "Home-Manager Migration Path" for step-by-step guide. Key principles:

- Migrate one tool at a time (start with zsh)
- Use `mkOutOfStoreSymlink` for configs that manage themselves (nvim/LazyVim)
- Use `programs.<tool>` modules for tools with native home-manager support (zsh, starship, bat, alacritty, git)
- Test each migration with `darwin-rebuild switch` before moving to next

## Important Notes

- Flake path: `~/repos/github/dotfiles/nix/`
- Rebuild alias: `dr` (defined in `zsh/aliases.zsh`)
- User: `adrianofsantos`
- All hosts are `aarch64-darwin` (Apple Silicon)
- Nix gc runs automatically, deleting generations older than 7 days
- Nix store optimization runs daily at 06:00
- There's a duplicate alias: `gc` is defined twice in aliases.zsh (git commit and git checkout)
