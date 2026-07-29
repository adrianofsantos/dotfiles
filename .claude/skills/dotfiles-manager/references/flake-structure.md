# Flake Structure Reference

## Current Architecture

```
dotfiles/
├── nix/
│   ├── flake.nix          # inputs, composição dos hosts (lista de módulos), bloco `let` com valores compartilhados
│   ├── flake.lock
│   ├── user.nix            # dados pessoais (username, email, gpgKey, paths) — criptografado com git-crypt
│   ├── user.nix.example    # template público de user.nix
│   ├── modules/
│   │   ├── common.nix       # Base: usuário, pacotes, Homebrew comum, stateVersion — todos os hosts
│   │   ├── personal.nix     # Casks/brews/masApps de máquinas pessoais (hoje: Aang e Kyoshi)
│   │   ├── macos-defaults.nix # system.defaults + Touch ID sudo + security.sudo.extraConfig
│   │   ├── nix-settings.nix # GC automático (7d), optimise diário, flakes habilitado
│   │   └── rosetta.nix      # nix-homebrew com Rosetta 2
│   ├── hosts/
│   │   ├── aang.nix          # masApps + Dock exclusivos do Aang
│   │   └── kyoshi.nix        # casks + brews + masApps + Dock exclusivos do Kyoshi
│   ├── home-common.nix       # Base home-manager: shell, git, neovim, starship, bat, claude configs
│   ├── home-aang.nix         # imports home-common.nix (sem divergências hoje)
│   └── home-kyoshi.nix       # imports home-common.nix + lazydocker + docker completions
├── nvim/, bat/, bpytop/, raycast/, starship.toml, claude/   # dotfiles linkados via mkOutOfStoreSymlink
└── .claude/skills/dotfiles-manager/   # esta skill
```

## Host Hierarchy

Não existe uma camada nomeada "commonConfiguration"/"personalConfiguration" no código — cada `darwinConfiguration` em `flake.nix` importa a mesma lista de módulos, na ordem:

```
modules/common.nix       → todos os hosts
modules/personal.nix     → hosts pessoais (hoje: Aang e Kyoshi, ambos pessoais)
modules/macos-defaults.nix
modules/nix-settings.nix
hosts/<host>.nix         → divergências exclusivas do host
nix-homebrew.darwinModules.nix-homebrew
modules/rosetta.nix
home-manager.darwinModules.home-manager → home-common.nix + home-<host>.nix
```

## Hosts

| Host   | Máquina             | Papel               | Divergências principais |
|--------|--------------------|--------------------|--------------------------|
| Aang   | MacBook Air        | Uso secundário      | Dock enxuto, masApps iWork/iMovie/GarageBand |
| Kyoshi | MacBook Pro        | Dev principal        | Docker Desktop, Xcode, homelab tools (talhelper, opentofu), lazydocker |

Ambos `aarch64-darwin` (Apple Silicon).

## Package Layers (estado atual)

### `environment.systemPackages`
- `modules/common.nix` (todos os hosts): gcal, git-crypt, gnupg, htop, imagemagick, ipcalc
- `modules/personal.nix` (pessoais): ipfetch

### `home.packages` (home-manager)
- `home-common.nix` (todos os hosts): cryptomator-cli (derivação custom), eza, fastfetch, fd, fzf, gitleaks, jq, krew, kubecolor, kubectx, lazygit, neovim, ripgrep, tree, wget
- `home-kyoshi.nix` (só Kyoshi): lazydocker

### Homebrew Casks
- `modules/common.nix`: appcleaner, brave-browser, cryptomator, firefox, obsidian, openmtp, visual-studio-code, raycast, warp
- `modules/personal.nix`: claude, claude-code, discord, fuse-t, proton-drive, proton-mail, proton-pass, protonvpn, telegram, vlc, whatsApp
- `hosts/kyoshi.nix`: android-studio, balenaetcher, calibre, docker-desktop, obs, ollama-app, proton-drive, qbittorrent, samsung-magician, steam, tradingview, veracrypt-fuse-t

### Homebrew Brews
- `modules/common.nix`: bpytop, gh, pinentry-mac, watch, mas
- `modules/personal.nix`: talosctl
- `hosts/kyoshi.nix`: gemini-cli, irssi, opentofu, talhelper, xcodegen

### Mac App Store (`homebrew.masApps`)
- `modules/personal.nix`: HP Smart
- `hosts/aang.nix`: GarageBand, iMovie, Keynote, Numbers, Pages
- `hosts/kyoshi.nix`: Xcode

## Adding a Package

1. Determine a camada:
   - CLI tool (nixpkgs, user-level) → `home.packages` em `home-common.nix` ou `home-<host>.nix`
   - CLI tool (nixpkgs, system-level) → `environment.systemPackages`
   - GUI app → `homebrew.casks`
   - CLI only in homebrew → `homebrew.brews`
   - Mac App Store only → `homebrew.masApps` (use `mas search <name>` para achar o ID)

2. Determine o escopo:
   - Todos os hosts → `modules/common.nix`
   - Máquinas pessoais → `modules/personal.nix`
   - Host único → `hosts/aang.nix` ou `hosts/kyoshi.nix` (system) / `home-aang.nix` ou `home-kyoshi.nix` (home-manager)

3. Rode `nix flake check ~/repos/github/dotfiles/nix/` e aplique: `dr` (`sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/`)

## Known Workarounds

- `users.users.${user.username}.home` em `modules/common.nix`: necessário porque home-manager seta `homeDirectory` como `null` no Darwin por default (bugs [#6557](https://github.com/nix-community/home-manager/issues/6557), #6036, #6743)
- `programs.zsh.initExtra` está deprecado desde home-manager 25.05 — usar `initContent` (já em uso em `home-common.nix`)
- Branch do home-manager deve seguir a mesma versão do `nixpkgs` pinado em `flake.nix` (hoje `nixpkgs-25.11-darwin` → `home-manager/release-25.11`). Não usar `master`
- Configs complexas (nvim, bat/themes, bpytop, raycast, starship.toml, claude/) usam `mkOutOfStoreSymlink` apontando para o repositório git em vez de serem convertidas para Nix puro — mantém os arquivos editáveis fora do Nix
