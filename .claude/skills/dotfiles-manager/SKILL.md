---
name: dotfiles-manager
description: >
  Gerenciamento de dotfiles e configurações para macOS com nix-darwin flakes e home-manager.
  Suporta múltiplos hosts (Aang, Kyoshi).
  Use para: (1) Adicionar/remover pacotes nos módulos (common.nix, personal.nix, hosts/*.nix, home-*.nix),
  (2) Bootstrap de máquina nova, (3) Auditoria de segurança (gitleaks, secrets no histórico git),
  (4) Gerenciar dotfiles e configs via home-manager, (5) Criar novo host no flake,
  (6) Alterar system.defaults/security.pam/security.sudo com validação de default.
  Triggers: dotfiles, flake, nix-darwin, darwin-rebuild, home-manager,
  pacote, package, bootstrap, segurança, security, gitleaks, secrets,
  sudo, pam, system defaults, timestamp_timeout.
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
6. **Alterar `system.defaults.*`, `security.pam.*` ou `security.sudo.*`?** → See "System Defaults / Security Settings" below

## Package Management

Before modifying módulos, read [references/flake-structure.md](references/flake-structure.md) to understand the host hierarchy and package layers.

### Adding a Package

1. Determine package type:
   - CLI tool (user-level) available in nixpkgs → `home.packages` em `nix/home-common.nix` (todos os hosts) ou `nix/home-<host>.nix` (host específico)
   - CLI tool (system-level, usado por root ou serviços) → `environment.systemPackages` em `nix/modules/common.nix`, `nix/modules/personal.nix` ou `nix/hosts/<host>.nix`
   - GUI app → `homebrew.casks` em `nix/modules/common.nix`, `nix/modules/personal.nix` ou `nix/hosts/<host>.nix`
   - CLI only in homebrew → `homebrew.brews` nos mesmos arquivos acima
   - Mac App Store → `homebrew.masApps` nos mesmos arquivos acima (run `mas search <name>` for ID)
   - Tool com módulo home-manager (ex: bat, starship, git) → `programs.<tool>` em `nix/home-common.nix`

2. Determine scope:
   - All machines → `nix/modules/common.nix`
   - Personal machines (hoje: Aang e Kyoshi, ambos pessoais) → `nix/modules/personal.nix`
   - Single host → `nix/hosts/aang.nix` ou `nix/hosts/kyoshi.nix`

3. Edit o(s) arquivo(s) do passo 1/2. `nix/flake.nix` só precisa ser tocado ao criar um host novo (ver bootstrap.md).

4. Rode `nix flake check ~/repos/github/dotfiles/nix/` (obrigatório antes de aplicar — ver CLAUDE.md do projeto).

5. Apply: `dr` (alias para `sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/`)

### Removing a Package

Same logic in reverse. Note: `homebrew.onActivation.cleanup = "zap"` ensures removed casks are uninstalled on next rebuild — se foi instalado manualmente com `brew install` e não declarado em nenhum módulo, também será removido.

## System Defaults / Security Settings

Antes de alterar `system.defaults.*`, `security.pam.*` ou `security.sudo.*`, o risco não é sintaxe (o Nix acusa isso), é aplicar um valor sem saber o comportamento real por trás dele.

1. Verifique o default que o **nix-darwin** atribui à opção:
   ```bash
   nix eval ~/repos/github/dotfiles/nix#darwinConfigurations.<Host>.options.<caminho.da.opção>.default
   ```
   Atenção: para opções do tipo `extraConfig` (texto bruto injetado, ex: `security.sudo.extraConfig`), esse default é tipicamente `null` — ele mostra apenas o default do *módulo nix-darwin*, não o comportamento da ferramenta subjacente.

2. Para o comportamento real, consulte a documentação da ferramenta, não só o `.default` do nix:
   - `security.sudo.extraConfig` → `man 5 sudoers` (ex: `timestamp_timeout` = 5 minutos por default do próprio `sudo`, não do nix-darwin)
   - `security.pam.services.*` → módulo nix-darwin (`nix eval ...options.security.pam.services.<serviço>.<opção>.default`) + `man 5 pam.d` para semântica
   - `system.defaults.*` → `defaults read <domain>` no macOS para ver o valor atual do sistema antes de sobrescrever

3. Rode `nix flake check ~/repos/github/dotfiles/nix/` após a mudança.

4. Aplique com `dr` e valide o efeito na prática (ex.: para `timestamp_timeout=15`, rodar `sudo -v` logo após o rebuild e cronometrar quanto tempo leva até o próximo `sudo` pedir senha de novo).

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

Dotfiles são gerenciados via home-manager em `nix/home-common.nix` (compartilhado por todos os hosts) e `nix/home-aang.nix` / `nix/home-kyoshi.nix` (imports de `home-common.nix` + divergências por host). Configs ficam em diretórios no root do repo (nvim/, bat/, bpytop/, raycast/, starship.toml) e são linkados via `mkOutOfStoreSymlink`. Tools com módulo nativo home-manager (zsh, git, starship, bat, zoxide) usam `programs.<tool>`.

### Adding a New Dotfile

1. Criar diretório no root do repo: `mkdir -p <tool>/`
2. Colocar config files dentro
3. Em `nix/home-common.nix` (ou no `home-<host>.nix` se for exclusivo de um host), adicionar entry com `mkOutOfStoreSymlink`:
   ```nix
   xdg.configFile."<tool>" = {
     source = config.lib.file.mkOutOfStoreSymlink
       "${user.dotfilesDir}/<tool>";
     force = true;
   };
   ```
   Ou usar `programs.<tool>` se existir módulo nativo no home-manager.
4. Adicionar ao `.gitignore` qualquer arquivo gerado/cache
5. Rode `nix flake check ~/repos/github/dotfiles/nix/`
6. Apply: `dr`

## Important Notes

- Flake path: `~/repos/github/dotfiles/nix/`
- Home-manager config: `~/repos/github/dotfiles/nix/home-common.nix` (compartilhado) + `home-aang.nix` / `home-kyoshi.nix` (por host)
- Rebuild alias: `dr` (definido em `programs.zsh.shellAliases` no `home-common.nix`)
- User: `adrianofsantos`
- All hosts are `aarch64-darwin` (Apple Silicon)
- Nix gc runs automatically, deleting generations older than 7 days
- Nix store optimization runs daily at 06:00
- GPG signing habilitado com chave `16D7D0D901DE83FB`

### Workarounds conhecidos

- `users.users.${user.username}.home` em `nix/modules/common.nix`: necessário porque home-manager seta homeDirectory como null no Darwin (bugs #6557, #6036, #6743)
- Branch do home-manager deve seguir a mesma versão do `nixpkgs` pinado no `flake.nix` (ex: `nixpkgs-25.11-darwin` → `home-manager/release-25.11`). Não usar `master`.
- `homebrew.onActivation.autoUpdate` deve permanecer `false` (ver CLAUDE.md do projeto § "Homebrew — Gotchas") — evita corromper a detecção do `mas` durante `brew bundle`.
