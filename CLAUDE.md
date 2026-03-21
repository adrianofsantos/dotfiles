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

## Rebuild

```bash
dr   # alias para: sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/
```
