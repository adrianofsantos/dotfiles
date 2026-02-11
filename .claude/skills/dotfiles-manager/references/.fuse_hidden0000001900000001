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
```nix
inputs = {
  # existing inputs...
  home-manager = {
    url = "github:nix-community/home-manager";
    inputs.nixpkgs.follows = "nixpkgs";
  };
};
```

### Phase 2: Create home module
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

### Phase 3: Migrate dotfiles incrementally
```nix
# home.nix
{ config, pkgs, ... }: {
  home.stateVersion = "24.05";

  # Example: migrate starship config
  programs.starship = {
    enable = true;
    # OR reference existing toml:
    # settings = builtins.fromTOML (builtins.readFile ../../starship.toml);
  };

  # Example: reference nvim config without converting
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/nvim";
  };

  # Example: zsh
  programs.zsh = {
    enable = true;
    shellAliases = {
      k = "kubectl";
      ls = "eza --icons";
      l = "ls --git -l";
      v = "nvim";
      lg = "lazygit";
      dr = "sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/";
    };
    initExtra = ''
      eval "$(zoxide init zsh)"
    '';
    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIX_CONF_DIR = "$HOME/.config/nix";
    };
  };
}
```

### Migration Order (recommended)
1. zsh (biggest win — eliminates .zshrc, aliases.zsh, functions.zsh)
2. starship (simple toml import)
3. bat (config + themes)
4. alacritty (toml config)
5. git (if adding git config later)
6. nvim (keep as-is with mkOutOfStoreSymlink — LazyVim manages itself)
7. Remove stow dependency from flake.nix
