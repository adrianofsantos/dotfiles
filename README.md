# dotfiles

Configuração declarativa de macOS via [nix-darwin](https://github.com/nix-darwin/nix-darwin) + [home-manager](https://github.com/nix-community/home-manager).

## Hosts

| Host | Máquina | Papel |
|------|---------|-------|
| **Aang** | MacBook Air (Apple Silicon) | Máquina secundária / uso geral |
| **Kyoshi** | MacBook Pro (Apple Silicon) | Máquina principal de desenvolvimento |

## Estrutura

```
dotfiles/
├── nix/
│   ├── flake.nix              # Entrada principal — composição dos hosts
│   ├── user.nix               # Dados do usuário (único arquivo a editar ao fazer fork)
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

## Setup em máquina nova

### 1. Instalar o Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Abrir um terminal novo após a instalação.

### 2. SSH key + clonar o repositório

```bash
ssh-keygen -t ed25519 -C "adriano.chico@gmail.com"
eval "$(ssh-agent -s)" && ssh-add ~/.ssh/id_ed25519
cat ~/.ssh/id_ed25519.pub | pbcopy
# Adicionar em: GitHub → Settings → SSH Keys

mkdir -p ~/repos/github && cd ~/repos/github
git clone git@github.com:adrianofsantos/dotfiles.git
```

### 3. Importar chave GPG + descriptografar user.nix

O `git-crypt` e `gnupg` são instalados pelo nix-darwin, mas o **primeiro build depende de `user.nix` decriptado** — um problema de chicken-and-egg. Instalar temporariamente via nix profile:

```bash
nix profile install nixpkgs#git-crypt nixpkgs#gnupg
```

Importar a chave GPG privada (transferir da outra máquina via AirDrop/USB):

```bash
# Na máquina de origem:
gpg --export-secret-keys 16D7D0D901DE83FB > ~/gpg-private.key

# Na máquina nova:
gpg --import gpg-private.key && rm gpg-private.key

# Definir confiança máxima (necessário para git-crypt)
gpg --fingerprint --with-colons 16D7D0D901DE83FB | \
  awk -F: '/^fpr/{print $10":6:"}' | gpg --import-ownertrust
```

Descriptografar:

```bash
cd ~/repos/github/dotfiles
git-crypt unlock
cat nix/user.nix  # deve mostrar conteúdo Nix legível
```

### 4. Primeiro build

```bash
cd ~/repos/github/dotfiles/nix
sudo darwin-rebuild switch --flake .#HOSTNAME  # Aang ou Kyoshi
```

Primeiro build leva ~15-30 min.

### 5. Configurar gpg-agent manualmente

O `gpg-agent.conf` **não é gerenciado pelo home-manager** — precisa ser criado manualmente após o primeiro build:

```bash
mkdir -p ~/.gnupg
cat > ~/.gnupg/gpg-agent.conf << 'EOF'
pinentry-program /opt/homebrew/bin/pinentry-mac
EOF
chmod 600 ~/.gnupg/gpg-agent.conf
```

Fazer logout/login para que o agente GPG reinicie com a nova configuração. Sem esse passo, `git commit` falha com `gpg: signing failed: No pinentry`.

### 6. Corrigir filtros do git-crypt

O `git-crypt unlock` registra caminhos absolutos nos filtros do `.git/config`. Após o build, o binário muda de lugar (de `nix profile` para `nix-darwin`), quebrando os filtros. Corrigir para usar PATH genérico:

```bash
cd ~/repos/github/dotfiles
git config filter.git-crypt.smudge '"git-crypt" smudge'
git config filter.git-crypt.clean '"git-crypt" clean'
git config filter.git-crypt.required true
git config diff.git-crypt.textconv '"git-crypt" diff'
```

### 7. Pós-instalação

```bash
# Remover pacotes temporários (já estão no sistema via nix-darwin)
nix profile remove nixpkgs#git-crypt nixpkgs#gnupg

# Abrir terminal novo para carregar shell configs
```

Checklist:
- [ ] `dr` funciona sem erros
- [ ] `git log --show-signature -1` mostra assinatura GPG válida
- [ ] Dock mostra os apps corretos
- [ ] Proton apps iniciam automaticamente
- [ ] Neovim abre com LazyVim (`v`)

> Para adicionar nova chave GPG como autorizada ao git-crypt:
> ```bash
> git-crypt add-gpg-user <FINGERPRINT>
> ```

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
