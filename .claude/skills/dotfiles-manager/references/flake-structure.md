# Flake Structure Reference

## Current Architecture

```
dotfiles/
├── nix/
│   ├── flake.nix          # Main system config
│   ├── flake.lock
│   ├── nix.conf
│   └── modules/
│       └── proton.nix     # LaunchAgent for Proton apps
├── zsh/                   # Shell config (stow-managed)
├── nvim/                  # LazyVim config (stow-managed)
├── alacritty/
├── bat/
├── bpytop/
├── starship.toml
├── fish/
├── neofetch/
├── brew/
├── iterm2/
└── config.sh              # Stow bootstrap script
```

## Host Hierarchy

```
commonConfiguration     → All machines (base packages, macOS defaults, nix settings)
  ├── personalConfiguration  → Personal machines (Proton, Podman, messaging apps)
  │   ├── aangConfigurations     → Mac "Aang" (aarch64-darwin, dock apps)
  │   └── kyoshiConfiguration   → Mac "Kyoshi" (aarch64-darwin, dev tools, dock apps)
  └── (future work configs)
```

## Hosts

| Host   | Machine       | Platform        | Role     |
|--------|--------------|-----------------|----------|
| Aang   | Mac (older)  | aarch64-darwin  | Personal |
| Kyoshi | Mac Mini M4  | aarch64-darwin  | Main dev |

## Package Layers

### System Packages (environment.systemPackages)
bat, eza, fastfetch, fd, fzf, gcal, gitleaks, gnupg, htop, imagemagick, ipcalc, jq, krew, kubecolor, kubectx, lazydocker, lazygit, neovim, ripgrep, starship, stow, tree, wget, zoxide

### Homebrew Brews
bpytop, gh, watch, mas, talosctl (personal), gemini-cli (Kyoshi)

### Homebrew Casks (common)
appcleaner, brave-browser, cryptomator, firefox, obsidian, openmtp, raycast, warp

### Homebrew Casks (per-host)
Aang: chatgpt, google-chrome
Kyoshi: balenaetcher, calibre, claude, claude-code, discord, docker-desktop, duckduckgo, ollama-app, qbittorrent, shortcat, tradingview, visual-studio-code

### Mac App Store
Perplexity (both), HP Smart (Kyoshi)

## Adding a Package

1. Determine the layer:
   - CLI tool → `environment.systemPackages` in `commonConfiguration`
   - GUI app available as brew cask → `homebrew.casks`
   - CLI only in homebrew → `homebrew.brews`
   - Mac App Store only → `homebrew.masApps` (use `mas search <name>` to find ID)

2. Determine the scope:
   - All machines → `commonConfiguration`
   - Personal machines → `personalConfiguration`
   - Single host → `aangConfigurations` or `kyoshiConfiguration`

3. Apply: `sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/`

## Home-Manager Migration Path

### Phase 1: Add home-manager input

IMPORTANT: Use the `release-XX.XX` branch matching your nixpkgs version. Example: nixpkgs-25.05-darwin → release-25.05.

```nix
inputs = {
  # existing inputs...
  home-manager = {
    url = "github:nix-community/home-manager/release-25.05";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### Phase 2: System-level user config (REQUIRED workaround)

home-manager's `nixos/common.nix` tries to read `users.users.<name>.home` from the system config.
On nix-darwin this is null by default, causing a build error. Fix: set it in `commonConfiguration`:

```nix
users.users.adrianofsantos.home = "/Users/adrianofsantos";
```

See: https://github.com/nix-community/home-manager/issues/6557

### Phase 3: Create home module
```nix
# In darwinConfigurations modules list, add:
home-manager.darwinModules.home-manager
{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.adrianofsantos = import ./home.nix;
  };
}
```

### Phase 4: Migrate dotfiles incrementally

NOTE: `programs.zsh.initExtra` is deprecated since home-manager 25.05. Use `initContent` instead.

For tools with complex configs (starship, alacritty), use `mkOutOfStoreSymlink` to reference the
existing config files instead of converting them to Nix. This keeps configs editable outside Nix.

```nix
# home.nix
{ config, pkgs, ... }: {
  home.username = "adrianofsantos";
  home.homeDirectory = "/Users/adrianofsantos";
  home.stateVersion = "24.05";

  programs.zsh = {
    enable = true;
    shellAliases = { /* ... */ };
    initContent = ''
      eval "$(starship init zsh)"
      eval "$(zoxide init zsh)"
    '';
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
    };
  };

  # Reference existing config files via symlink (no Nix conversion needed)
  xdg.configFile."starship.toml".source = config.lib.file.mkOutOfStoreSymlink
    "/Users/adrianofsantos/repos/github/dotfiles/starship.toml";
  xdg.configFile."nvim".source = config.lib.file.mkOutOfStoreSymlink
    "/Users/adrianofsantos/repos/github/dotfiles/nvim";
  xdg.configFile."alacritty".source = config.lib.file.mkOutOfStoreSymlink
    "/Users/adrianofsantos/repos/github/dotfiles/alacritty";
}
```

### Migration Order (recommended)
1. ✅ zsh (biggest win — eliminates .zshrc, aliases.zsh, functions.zsh)
2. ✅ starship (symlink to existing toml)
3. ✅ bat (config via programs.bat + symlink themes)
4. ✅ alacritty (symlink to existing toml)
5. nvim (keep as-is with mkOutOfStoreSymlink — LazyVim manages itself)
6. git (if adding git config later)
7. Remove stow dependency from flake.nix
