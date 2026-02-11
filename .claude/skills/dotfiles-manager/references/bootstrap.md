# Bootstrap Reference — New Machine Setup

## Prerequisites

- macOS (Apple Silicon)
- Admin access
- Internet connection

## Bootstrap Sequence

### 1. Generate SSH Key (if needed)
```bash
ssh-keygen -t ed25519 -C "adriano.chico@gmail.com"
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
# Copy public key and add to GitHub → Settings → SSH Keys
cat ~/.ssh/id_ed25519.pub | pbcopy
```

### 2. Install Nix
```bash
curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install
```
The Determinate Systems installer is recommended over official — handles macOS quirks better, auto-configures daemon.

### 3. Clone Dotfiles
```bash
mkdir -p ~/repos/github
cd ~/repos/github
git clone git@github.com:adrianofsantos/dotfiles.git
# or with HTTPS if SSH not yet configured:
# git clone https://github.com/adrianofsantos/dotfiles.git
```

### 4. First Build
```bash
cd ~/repos/github/dotfiles/nix
# Replace HOSTNAME with Aang, Kyoshi, or new host name
darwin-rebuild switch --flake .#HOSTNAME
```

This installs: all system packages, homebrew casks, Mac App Store apps, configures macOS defaults.

First build takes ~15-30 min (downloads nixpkgs, compiles some packages, installs homebrew casks).

### 5. Apply Dotfiles

**Current (stow):**
```bash
cd ~/repos/github/dotfiles
./config.sh
```

**After home-manager migration:**
Dotfiles are applied automatically by `darwin-rebuild switch`.

### 6. Post-Bootstrap Checklist

- [ ] SSH key added to GitHub (done in step 1)
- [ ] GPG key configured (if using signed commits)
- [ ] Run `gitleaks git -v --log-opts="--all" .` on dotfiles repo
- [ ] Install pre-commit hook (see security reference)
- [ ] Verify Proton apps auto-start (Kyoshi only — check launchd agents)
- [ ] Verify dock apps are correct
- [ ] Test `dr` alias (`darwin-rebuild switch`)

## Adding a New Host

1. Create host configuration in `flake.nix`:
```nix
newHostConfiguration = { pkgs, ... }: {
  nixpkgs.hostPlatform = "aarch64-darwin"; # or x86_64-darwin
  environment.systemPackages = [
    # host-specific packages
  ];
  homebrew = {
    enable = true;
    casks = [ /* host-specific casks */ ];
  };
  system.defaults = {
    dock.persistent-apps = [ /* host dock apps */ ];
  };
};
```

2. Add to darwinConfigurations:
```nix
darwinConfigurations."NewHost" = nix-darwin.lib.darwinSystem {
  modules = [
    commonConfiguration
    # personalConfiguration  # if personal machine
    newHostConfiguration
    nix-homebrew.darwinModules.nix-homebrew
    rosettaHomebrewModule
  ];
};
```

3. Build: `darwin-rebuild switch --flake .#NewHost`

## Linux Support (Future)

For Ubuntu/Fedora, the nix-darwin modules won't apply. Strategy:
- Use standalone home-manager (not nix-darwin module)
- Share dotfiles configs via home-manager modules
- System packages via distro package manager or nix profile
- Create a separate `nixosConfigurations` or `homeConfigurations` output in flake.nix

```nix
# Future flake.nix addition:
homeConfigurations."adriano@ubuntu" = home-manager.lib.homeManagerConfiguration {
  pkgs = nixpkgs.legacyPackages.x86_64-linux;
  modules = [ ./home-manager/common.nix ./home-manager/linux.nix ];
};
```
