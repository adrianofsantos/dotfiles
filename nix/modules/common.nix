{ pkgs, self, ... }:

{
  system.primaryUser = "adrianofsantos";
  users.users.adrianofsantos.home = "/Users/adrianofsantos";
  nixpkgs.config.allowUnfree = false;
  nixpkgs.hostPlatform = "aarch64-darwin"; # ambas as máquinas são Apple Silicon

  fonts.packages = with pkgs; [
    nerd-fonts.hack
  ];

  environment.systemPackages = with pkgs; [
    gcal
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
      "obsidian"
      "openmtp"
      "raycast"
      "warp"
    ];
    brews = [
      "bpytop"
      "gh"
      "watch"
      "mas"
    ];
    onActivation = {
      cleanup = "zap";
      autoUpdate = true;
      upgrade = true;
    };
  };

  system.configurationRevision = self.rev or self.dirtyRev or null;
  system.stateVersion = 5;
}
