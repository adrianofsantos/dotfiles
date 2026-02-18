---
name: dotfiles-manager
description: >
  Gerenciamento de dotfiles e configurações para macOS com nix-darwin flakes e home-manager.
  Suporta múltiplos hosts (Aang, Kyoshi).
  Use para: (1) Adicionar/remover pacotes no flake.nix ou home.nix,
  (2) Bootstrap de máquina nova, (3) Auditoria de segurança (gitleaks, secrets no histórico git),
  (4) Gerenciar dotfiles e configs via home-manager, (5) Criar novo host no flake.
  Triggers: dotfiles, flake, nix-darwin, darwin-rebuild, home-manager,
  pacote, package, bootstrap, segurança, security, gitleaks, secrets.
---

# Dotfiles Manager

Skill para gerenciar o repositório de dotfiles do Adriano — nix-darwin flakes + home-manager, múltiplos hosts macOS.

Read [references/flake-structure.md](references/flake-structure.md) to understand the current repo layout, host hierarchy, and package layers.

## Workflow Decision Tree

1. **Adicionar/remover pacote?** → See "Package Management" below
2. **Configurar máquina nova?** → Read [references/bootstrap.md](references/bootstrap.md)
3. **Auditoria de segurança?** → See "Security" below
4. **Adicionar/editar dotfile?** → See "Dotfile Management" below
5. **Criar novo host?** → Read [references/bootstrap.md](references/bootstrap.md) § "Adding a New Host"

## Package Management

Before modifying `flake.nix`, read [references/flake-structure.md](references/flake-structure.md) to understand the host hierarchy and package layers.

### Adding a Package

1. Determine package type:
   - CLI tool (user-level) available in nixpkgs → `home.packages` em `nix/home.nix`
   - CLI tool (system-level, usado por root ou serviços) → `environment.systemPackages` em `nix/flake.nix`
   - GUI app → `homebrew.casks` em `nix/flake.nix`
   - CLI only in homebrew → `homebrew.brews` em `nix/flake.nix`
   - Mac App Store → `homebrew.masApps` (run `mas search <name>` for ID)
   - Tool com módulo home-manager (ex: bat, starship, git) → `programs.<tool>` em `nix/home.nix`

2. Determine scope (para homebrew/system packages no flake.nix):
   - All machines → `commonConfiguration`
   - Personal machines → `personalConfiguration`
   - Single host → host-specific config (e.g. `kyoshiConfiguration`)

3. Edit `nix/flake.nix` e/ou `nix/home.nix` accordingly.

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

### Current State (home-manager)

Dotfiles são gerenciados via home-manager em `nix/home.nix`. Configs ficam em diretórios no root do repo (nvim/, bat/, bpytop/, raycast/, starship.toml) e são linkados via `mkOutOfStoreSymlink`. Tools com módulo nativo home-manager (zsh, git, starship, bat, zoxide) usam `programs.<tool>`.

### Adding a New Dotfile

1. Criar diretório no root do repo: `mkdir -p <tool>/`
2. Colocar config files dentro
3. Em `nix/home.nix`, adicionar entry com `mkOutOfStoreSymlink`:
   ```nix
   xdg.configFile."<tool>" = {
     source = config.lib.file.mkOutOfStoreSymlink
       "${dotfilesPath}/<tool>";
   };
   ```
   Ou usar `programs.<tool>` se existir módulo nativo no home-manager.
4. Adicionar ao `.gitignore` qualquer arquivo gerado/cache
5. Apply: `darwin-rebuild switch`

## Important Notes

- Flake path: `~/repos/github/dotfiles/nix/`
- Home-manager config: `~/repos/github/dotfiles/nix/home.nix`
- Rebuild alias: `dr` (defined em `programs.zsh.shellAliases` no home.nix)
- User: `adrianofsantos`
- All hosts are `aarch64-darwin` (Apple Silicon)
- Nix gc runs automatically, deleting generations older than 7 days
- Nix store optimization runs daily at 06:00
- GPG signing habilitado com chave `16D7D0D901DE83FB`

### Workarounds conhecidos

- `users.users.adrianofsantos.home` no flake.nix: necessário porque home-manager seta homeDirectory como null no Darwin (bugs #6557, #6036, #6743)
- Branch do home-manager deve ser `release-25.05` (matching nixpkgs-25.05-darwin). Não usar `master`.
