# Bootstrap — Configuração de máquina nova

Guia completo para configurar um Mac novo (ou recém-formatado) do zero usando este repositório.

## Pré-requisitos

- macOS em Apple Silicon (M1+)
- Acesso de administrador
- Conexão com a internet
- Acesso à chave GPG privada (exportada de outra máquina ou backup)

## Etapas

### 1. Instalar o Nix

```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```

Usar o instalador da Determinate Systems — lida melhor com as particularidades do macOS e configura o daemon automaticamente. Após instalar, abrir um terminal novo para que o `nix` esteja no PATH.

### 2. Gerar chave SSH e adicionar ao GitHub

```bash
ssh-keygen -t ed25519 -C "adriano.chico@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519

# Copiar chave pública para a área de transferência
cat ~/.ssh/id_ed25519.pub | pbcopy
```

Ir em [GitHub → Settings → SSH Keys](https://github.com/settings/keys) e adicionar a chave copiada.

### 3. Clonar o repositório

```bash
mkdir -p ~/repos/github
cd ~/repos/github
git clone git@github.com:adrianofsantos/dotfiles.git
```

Se o SSH ainda não estiver configurado, usar HTTPS temporariamente:
```bash
git clone https://github.com/adrianofsantos/dotfiles.git
```

### 4. Importar chave GPG

A chave GPG é necessária para duas coisas: descriptografar `user.nix` (git-crypt) e assinar commits. Transferir a chave privada da outra máquina ou de um backup.

**Na máquina de origem (ex: Kyoshi):**
```bash
gpg --export-secret-keys 16D7D0D901DE83FB > ~/gpg-private.key
# Transferir o arquivo para a máquina nova (AirDrop, USB, etc.)
```

**Na máquina nova:**
```bash
gpg --import gpg-private.key
rm gpg-private.key  # apagar após importar
```

Definir confiança máxima na chave (necessário para que o git-crypt aceite a chave):
```bash
gpg --fingerprint --with-colons 16D7D0D901DE83FB | \
  awk -F: '/^fpr/{print $10":6:"}' | \
  gpg --import-ownertrust
```

Verificar se a chave está correta:
```bash
gpg --list-secret-keys
```

### 5. Descriptografar user.nix (git-crypt)

O `git-crypt` e o `gnupg` são instalados pelo nix-darwin (em `common.nix`), mas **o primeiro build depende de `user.nix` estar decriptado**. É um problema de chicken-and-egg. A solução é instalar temporariamente via nix profile:

```bash
nix profile install nixpkgs#git-crypt nixpkgs#gnupg
```

Agora descriptografar:
```bash
cd ~/repos/github/dotfiles
git-crypt unlock
```

Verificar se funcionou:
```bash
cat nix/user.nix
# Deve mostrar o conteúdo nix legível, não bytes binários
```

### 6. Primeiro build

```bash
cd ~/repos/github/dotfiles/nix
sudo darwin-rebuild switch --flake .#HOSTNAME
```

Substituir `HOSTNAME` pelo nome da máquina: `Aang` ou `Kyoshi`.

O primeiro build leva ~15-30 min (baixa nixpkgs, compila pacotes, instala Homebrew casks e Mac App Store apps).

### 7. Corrigir filtros do git-crypt

O `git-crypt unlock` registra caminhos absolutos no `.git/config` (ex: `/nix/store/.../git-crypt`). Após o primeiro build, o `git-crypt` muda de lugar (de `nix profile` para `/run/current-system/sw/bin/`), e os filtros ficam apontando para o path antigo — causando erros como `No such file or directory` em cada operação git.

Corrigir para usar PATH genérico:
```bash
cd ~/repos/github/dotfiles
git config filter.git-crypt.smudge '"git-crypt" smudge'
git config filter.git-crypt.clean '"git-crypt" clean'
git config filter.git-crypt.required true
git config diff.git-crypt.textconv '"git-crypt" diff'
```

### 8. Remover pacotes temporários

Após o build, `git-crypt` e `gnupg` já estão no sistema via nix-darwin. Remover as versões temporárias do nix profile:

```bash
nix profile remove nixpkgs#git-crypt nixpkgs#gnupg
```

### 9. Logout e login

Após o primeiro build, fazer logout e login completo (não apenas fechar o terminal). Isso é necessário para:
- Carregar as configurações de shell (aliases, starship, zoxide, completions)
- Iniciar o `gpg-agent` configurado pelo home-manager com `pinentry_mac`
- Ativar Login Items do macOS (ProtonVPN, ProtonDrive)

```
Apple menu → Log Out → (confirmar) → Login
```

> **Atenção:** sem logout/login, o `gpg-agent` antigo (sem pinentry configurado) pode continuar rodando e commits assinados falharão com `gpg: signing failed: No pinentry`.

## Checklist pós-instalação

- [ ] `dr` funciona (rebuild rápido sem erros)
- [ ] Logout e login realizados (gpg-agent e Login Items precisam de nova sessão)
- [ ] `git log --show-signature -1` mostra assinatura GPG válida
- [ ] Dock mostra os apps corretos para o host
- [ ] Proton apps iniciam automaticamente (via Login Items do macOS)
- [ ] `cryptomator-cli --version` funciona
- [ ] Neovim abre com LazyVim configurado (`v` no terminal)
- [ ] Starship prompt aparece corretamente

## Adicionar novo host

### 1. Criar arquivo do host

```bash
# nix/hosts/novohost.nix
{ ... }:

{
  homebrew = {
    casks = [
      # casks exclusivos deste host
    ];
    brews = [
      # brews exclusivos
    ];
  };

  system.defaults = {
    dock.persistent-apps = [
      # apps no dock
    ];
  };
}
```

### 2. Criar home do host

```bash
# nix/home-novohost.nix
{ pkgs, lib, ... }:

{
  imports = [ ./home-common.nix ];

  # Pacotes exclusivos deste host
  home.packages = with pkgs; [
  ];
}
```

### 3. Adicionar ao flake.nix

```nix
darwinConfigurations."NovoHost" = nix-darwin.lib.darwinSystem {
  specialArgs = { inherit self user; };
  modules = [
    ./modules/common.nix
    ./modules/personal.nix
    ./modules/macos-defaults.nix
    ./modules/nix-settings.nix
    ./hosts/novohost.nix
    nix-homebrew.darwinModules.nix-homebrew
    ./modules/rosetta.nix
    home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = { inherit user; };
        users.${user.username} = import ./home-novohost.nix;
      };
    }
  ];
};
```

### 4. Build

```bash
sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/#NovoHost
```

## Adicionar novo colaborador ao git-crypt

Para que outra pessoa (ou outra chave GPG) possa descriptografar `user.nix`:

```bash
# Primeiro definir confiança na chave do colaborador
gpg --fingerprint --with-colons <KEY_ID> | \
  awk -F: '/^fpr/{print $10":6:"}' | \
  gpg --import-ownertrust

# Adicionar ao git-crypt (gera um commit automaticamente)
git-crypt add-gpg-user <FINGERPRINT>
```

## Troubleshooting

### `user.nix` aparece como binário
```
error: syntax error, unexpected end of file
at nix/user.nix:1:2: GITCRYPT...
```
**Causa:** git-crypt não foi destrancado nesta máquina.
**Solução:** `git-crypt unlock`

### `nix search` mostra pacote que não existe no build
**Causa:** `nix search nixpkgs` busca no registry global (geralmente unstable), não na versão pinada do flake.
**Solução:** Buscar na versão correta:
```bash
nix search github:NixOS/nixpkgs/nixpkgs-25.11-darwin <pacote>
```
Ou verificar em [search.nixos.org](https://search.nixos.org/packages) com o canal correto selecionado.

### `git-crypt: No such file or directory` em cada comando
```
--: /opt/homebrew/bin/git-crypt: No such file or directory
```
**Causa:** O `git-crypt unlock` registra caminhos absolutos nos filtros do `.git/config`. Se o binário mudou de lugar (ex: de homebrew/nix-profile para nix-darwin), os filtros ficam quebrados. O starship (prompt) checa git status a cada comando, disparando o erro repetidamente.
**Solução:**
```bash
cd ~/repos/github/dotfiles
git config filter.git-crypt.smudge '"git-crypt" smudge'
git config filter.git-crypt.clean '"git-crypt" clean'
git config filter.git-crypt.required true
git config diff.git-crypt.textconv '"git-crypt" diff'
```

### Hash mismatch ao adicionar pacote customizado
**Causa:** A versão do pacote mudou mas o hash não foi atualizado.
**Solução:** O nix mostra o hash correto no erro. Usar o valor de `got:` para substituir o `sha256` na derivação.
