{ pkgs, self, user, ... }:

{
  system.primaryUser = user.username;
  users.users.${user.username}.home = user.homeDir;
  nixpkgs.config.allowUnfree = false;
  nixpkgs.hostPlatform = "aarch64-darwin"; # ambas as máquinas são Apple Silicon

  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  environment.systemPackages = with pkgs; [
    gcal
    git-crypt
    gnupg
    htop
    imagemagick
    ipcalc
  ];

  homebrew = {
    enable = true;
    casks = [
      "appcleaner"
      "brave-browser"
      "cryptomator"
      "firefox"
      "ghostty"
      "obsidian"
      "openmtp"
      "raycast"
      "visual-studio-code"
      "warp"
    ];
    brews = [
      "bpytop"
      "gh"
      "herdr"
      "pinentry-mac"
      "watch"
      "mas"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = false;
      upgrade = true;
    };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
}
