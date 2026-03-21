# dotfiles

Configuração declarativa de macOS via [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager).

## Hosts

| Host | Máquina | Papel |
|------|---------|-------|
| **Aang** | MacBook Air (Apple Silicon) | Backup pessoal / máquina principal da esposa |
| **Kyoshi** | MacBook Pro (Apple Silicon) | Máquina principal de desenvolvimento |

## Estrutura

```
dotfiles/
├── nix/
│   ├── flake.nix              # Entrada principal — composição dos hosts
│   ├── flake.lock             # Dependências fixadas
│   ├── home-common.nix        # Base compartilhada do home-manager
│   ├── home-aang.nix          # Home do Aang (importa common)
│   ├── home-kyoshi.nix        # Home da Kyoshi (importa common + Docker)
│   ├── modules/
│   │   ├── common.nix         # Pacotes, Homebrew e configurações base
│   │   ├── personal.nix       # Apps pessoais (Proton suite, Claude, etc.)
│   │   ├── macos-defaults.nix # Preferências do macOS (dock, finder, etc.)
│   │   ├── nix-settings.nix   # Daemon Nix (GC, otimização, flakes)
│   │   ├── rosetta.nix        # nix-homebrew + Rosetta 2 para Apple Silicon
│   │   └── proton.nix         # NSAppSleepDisabled para ProtonVPN e Drive
│   └── hosts/
│       ├── aang.nix           # Casks e dock específicos do Aang
│       └── kyoshi.nix         # Casks, brews e dock específicos da Kyoshi
├── nvim/                      # Configuração Neovim (LazyVim)
├── bat/                       # Temas Catppuccin para bat
├── bpytop/                    # Configuração e temas para bpytop
├── starship.toml              # Prompt do shell
└── claude/                    # Configuração do Claude Code
```

## Composição dos módulos

```
commonConfiguration   →  base de tudo (ambas as máquinas)
personalConfiguration →  apps pessoais (ambas as máquinas)
macos-defaults        →  preferências macOS (ambas as máquinas)
nix-settings          →  GC, otimização (ambas as máquinas)
rosetta               →  nix-homebrew + Rosetta 2 (Apple Silicon)
proton                →  App Nap desativado para ProtonVPN/Drive (Aang)
hosts/aang.nix        →  dock e casks exclusivos do Aang
hosts/kyoshi.nix      →  dock, casks e brews exclusivos da Kyoshi
```

## Onde adicionar pacotes

| O que adicionar | Onde |
|-----------------|------|
| Pacote Nix para todas as máquinas | `modules/common.nix` → `environment.systemPackages` |
| Cask Homebrew para todas as máquinas | `modules/common.nix` → `homebrew.casks` |
| App pessoal (Proton, Claude, etc.) | `modules/personal.nix` |
| Pacote Nix só para o Aang | `hosts/aang.nix` |
| Pacote Nix só para a Kyoshi | `hosts/kyoshi.nix` |
| Ferramenta de linha de comando no shell | `home-common.nix` → `home.packages` |
| Ferramenta só na Kyoshi (ex: Docker) | `home-kyoshi.nix` → `home.packages` |

## Comandos

```bash
# Aplicar configuração (rodar na máquina alvo)
sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/

# Build sem aplicar (teste)
darwin-rebuild build --flake ~/repos/github/dotfiles/nix/#Aang
darwin-rebuild build --flake ~/repos/github/dotfiles/nix/#Kyoshi

# Atualizar dependências do flake
nix flake update --flake ~/repos/github/dotfiles/nix/
```

## Alias disponível

O alias `dr` no shell executa o rebuild completo:

```bash
dr  # equivale a: sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/
```
