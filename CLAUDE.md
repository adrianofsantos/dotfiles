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
│   └── kyoshi.nix         # Dock + casks + brews exclusivos (docker, steam, etc.)
├── home-common.nix        # Base home-manager: shell, git, neovim, starship
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

## Decisões arquiteturais

- **Aang é enxuto**: sem container runtime (Docker/Podman), sem ferramentas pesadas. CLIs de gerenciamento (talosctl, kubectx) são mantidas pois não consomem recursos em idle
- **Kyoshi tem Docker Desktop**: não Podman. Docker Desktop expõe o socket padrão que os MCP servers esperam
- **home-common.nix** contém toda a config compartilhada — hosts só declaram divergências
- **fuse-t** permanece no `personal.nix` pois o Cryptomator depende dele para montar volumes no macOS

## Segurança

- `nix/user.nix` está criptografado com git-crypt — ao clonar em máquina nova rodar `git-crypt unlock` após configurar a chave GPG
- Antes de `git-crypt add-gpg-user`, definir confiança GPG: `gpg --fingerprint --with-colons <KEY_ID> | awk -F: '/^fpr/{print $10":6:"}' | gpg --import-ownertrust`
- `nix/user.nix.example` existe como template público — `user.nix` real nunca aparece em plaintext no repositório remoto

## GPG / Commit Signing

- `pinentry-mac` via brew (em `common.nix` → `homebrew.brews`) — não nixpkgs
- `~/.gnupg/gpg-agent.conf` gerenciado manualmente (não via home-manager) com `pinentry-program /opt/homebrew/bin/pinentry-mac`
- Sem pinentry: `git commit` falha com `gpg: signing failed: No pinentry`
- Após alterar gpg-agent: logout/login obrigatório (agente antigo continua na sessão)

## home-manager — Gotchas

- Se um arquivo já existe no sistema e o home-manager tenta gerenciá-lo, o rebuild falha com `would be clobbered` — remover o arquivo manualmente antes de rodar `dr`

## README — bootstrap

- A seção "Setup em máquina nova" do README é o guia canônico de bootstrap — não remover nem enxugar; é a única documentação dos passos manuais pré-`dr`

## Rebuild

```bash
dr   # alias para: sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/
```
