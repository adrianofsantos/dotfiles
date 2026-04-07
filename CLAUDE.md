# Contexto para Claude

Repositório de dotfiles para macOS com nix-darwin + home-manager.
Dois hosts Apple Silicon: **Aang** (MacBook Air, uso secundário) e **Kyoshi** (MacBook Pro, desenvolvimento principal).

## Estrutura dos módulos Nix

```
nix/
├── flake.nix              # Apenas inputs e composição dos hosts
├── modules/
│   ├── common.nix         # Base: usuário, pacotes, Homebrew, stateVersion
│   ├── personal.nix       # Proton suite, Claude, fuse-t, talosctl
│   ├── macos-defaults.nix # system.defaults + Touch ID sudo
│   ├── nix-settings.nix   # GC automático (7d), optimise, flakes
│   ├── rosetta.nix        # nix-homebrew com Rosetta 2
│   └── proton.nix         # NSAppSleepDisabled para ProtonVPN e ProtonDrive
├── hosts/
│   ├── aang.nix           # Dock + casks exclusivos (chatgpt, google-chrome)
│   └── kyoshi.nix         # Dock + casks + brews exclusivos (docker, steam, homelab tools)
├── home-common.nix        # Base home-manager: shell, git, neovim, starship, claude configs
├── home-aang.nix          # imports home-common (sem lazydocker, sem docker completions)
└── home-kyoshi.nix        # imports home-common + lazydocker + docker completions
```

## Convenções

- Listas Homebrew (`casks`, `brews`) são **mergeadas automaticamente** pelo módulo system — cada módulo só declara o seu incremento, sem repetir o que já está no common
- `nixpkgs.hostPlatform = "aarch64-darwin"` está em `common.nix` — vale para ambos os hosts
- `specialArgs = { inherit self user; }` passa `self.rev` e dados do usuário aos módulos do sistema
- `extraSpecialArgs = { inherit user; }` passa os mesmos dados aos módulos do home-manager
- Dados pessoais (username, email, gpgKey, paths) estão centralizados em `user.nix` — único arquivo a editar ao fazer fork
- `home-manager` usa `lib.mkAfter` para concatenar `initContent` de zsh entre módulos
- ProtonVPN e ProtonDrive usam Login Items nativos do macOS — o `proton.nix` só desativa o App Nap, sem LaunchAgents (que causavam duplicação de processos)

## Homebrew — Gotchas

- `homebrew.onActivation.autoUpdate` **deve permanecer `false`** — definir como `true` permite que o `brew bundle` dispare um auto-update interno que corrompe a detecção do `mas`, causando `mas installation failed` mesmo com o app já instalado. Com `autoUpdate = false`, o nix-darwin passa `HOMEBREW_NO_AUTO_UPDATE=1` ao chamar `brew bundle`
- `homebrew.onActivation.cleanup = "zap"` remove **qualquer** pacote brew não declarado em nenhum módulo no próximo `dr` — se instalar algo manualmente com `brew install`, declarar no módulo correspondente ou será desinstalado

## Decisões arquiteturais

- **Aang é enxuto**: sem container runtime (Docker/Podman), sem ferramentas pesadas. CLIs de gerenciamento (talosctl, kubectx) são mantidas pois não consomem recursos em idle
- **Kyoshi tem Docker Desktop**: não Podman. Docker Desktop expõe o socket padrão que os MCP servers esperam
- **home-common.nix** contém toda a config compartilhada — hosts só declaram divergências
- **fuse-t** permanece no `personal.nix` pois o Cryptomator depende dele para montar volumes no macOS

## Claude Code

- `claude/CLAUDE.md`, `claude/settings.json` e `claude/statusline-command.sh` são gerenciados pelo `home-common.nix` via `mkOutOfStoreSymlink` — alterações nos arquivos fonte têm efeito imediato sem `dr`
- `claude/CLAUDE.md` é o global CLAUDE.md (`~/.claude/CLAUDE.md`) — contém o workflow Pesquisa→Spec→Code e vale para todos os projetos
- `claude/settings.json` e `claude/statusline-command.sh` são públicos no repositório — não incluir tokens, chaves ou dados pessoais nesses arquivos
- Após bootstrap: rodar `claude` para autenticar via browser antes de usar

## Segurança

- `nix/user.nix` está criptografado com git-crypt — ao clonar em máquina nova rodar `git-crypt unlock` após configurar a chave GPG
- Antes de `git-crypt add-gpg-user`, definir confiança GPG: `gpg --fingerprint --with-colons <KEY_ID> | awk -F: '/^fpr/{print $10":6:"}' | gpg --import-ownertrust`
- `nix/user.nix.example` existe como template público — `user.nix` real nunca aparece em plaintext no repositório remoto

## GPG / Commit Signing

- `pinentry-mac` via brew (em `common.nix` → `homebrew.brews`) — não nixpkgs
- `~/.gnupg/gpg-agent.conf` gerenciado manualmente (não via home-manager) com `pinentry-program /opt/homebrew/bin/pinentry-mac`
- Sem pinentry: `git commit` falha com `gpg: signing failed: No pinentry`
- Após alterar gpg-agent: logout/login obrigatório (agente antigo continua na sessão)

## Nix — Gotchas

- `nix search nixpkgs` busca no registry global (geralmente unstable), não na versão pinada do flake. Usar: `nix search github:NixOS/nixpkgs/nixpkgs-25.11-darwin <pacote>`
- `with pkgs;` trata hífens como subtração — pacotes com hífen falham silenciosamente. Usar `pkgs."nome-com-hífen"` dentro de um bloco `with pkgs;`, ou referenciar sem `with`

## home-manager — Gotchas

- Se um arquivo já existe no sistema e o home-manager tenta gerenciá-lo, o rebuild falha com `would be clobbered` — remover o arquivo manualmente antes de rodar `dr`

## README — bootstrap

- A seção "Setup em máquina nova" do README é o guia canônico de bootstrap — não remover nem enxugar; é a única documentação dos passos manuais pré-`dr`

## Neovim — Gotchas

- `nvim/` usa `mkOutOfStoreSymlink` mas a cadeia passa pelo Nix store: `~/.config/nvim` → store intermediário → `~/repos/github/dotfiles/nvim`. Alterações em `nvim/` requerem `dr` para efeito (diferente dos arquivos `claude/` que são symlinks diretos)
- LazyVim com `install_version >= 8` (ver `~/.config/nvim/lazyvim.json`): picker padrão é **snacks.nvim**, não telescope. Explorer padrão é **snacks explorer**, não neo-tree. Configurar via `opts.picker.sources.files` e `opts.picker.sources.explorer`
- No snacks picker, a opção para arquivos gitignored é `ignored = true` (não `no_ignore`); para dotfiles é `hidden = true`

## Rebuild

```bash
dr   # alias para: sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/

# Atualizar dependências do flake (pinagem de versões)
nix flake update --flake ~/repos/github/dotfiles/nix/
```
