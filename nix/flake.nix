{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  #outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-bundle }:
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    commonConfiguration = { pkgs, ... }: {
      system.primaryUser = "adrianofsantos";
      nixpkgs.config.allowUnfree = true;
      # Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.hack
      ];
      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wgepkgs.wgett
      environment.systemPackages = [
        pkgs.ansible
        pkgs.bat
        pkgs.eza
        pkgs.fastfetch
        pkgs.fd
        pkgs.fzf
        pkgs.gcal
        pkgs.gitleaks
        pkgs.gnupg
        pkgs.htop
        pkgs.imagemagick
        pkgs.ipcalc
        pkgs.jq
        pkgs.krew
        pkgs.kubecolor
        pkgs.kubectx
        pkgs.lazydocker
        pkgs.lazygit
        pkgs.neovim
        pkgs.obsidian
        pkgs.ripgrep
        pkgs.starship
        pkgs.stow
        pkgs.tree
        pkgs.wget
        pkgs.zoxide
      ];

      homebrew = {
        enable = true;
        casks = [
          "alacritty"
          "appcleaner"
          "brave-browser"
          "cryptomator"
          "diskspace"
          "firefox"
          "microsoft-edge"
          "openmtp"
          "raycast"
          "visual-studio-code"
          "warp"
        ];
        brews = [
          "bpytop"
          "gh"
          "watch"
          "mas"
        ];
        masApps = {
          "Perplexity ask anything" = 6714467650;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.autohide = true;
        dock.autohide-delay = 0.25;
        finder.AppleShowAllExtensions = true;
        finder.FXPreferredViewStyle = "clmv";
        screencapture.target = "file";
        screencapture.location = "~/Pictures/screenshots";
        screensaver.askForPasswordDelay = 10;
        loginwindow.LoginwindowText = "“Seja a mudança que você quer ver no mundo.“ – Mahatma Gandhi";
        loginwindow.GuestEnabled = false;
        menuExtraClock.Show24Hour = true;
        menuExtraClock.ShowDate = 0;
      };
      
      # Descontinuado.
      #security.pam.enableSudoTouchIdAuth = true;
      #nix.useDaemon = true;
      # Substituição dos itens acima
      security.pam.services.sudo_local.touchIdAuth = true; #default false
      nix.enable = true; #defaul true

      # Necessary for using flakes on this system.
      nix.settings.experimental-features = "nix-command flakes";

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;

      # The platform the configuration will be used on.
      #nixpkgs.hostPlatform = "aarch64-darwin";
    };

    personalConfiguration = { pkgs, ... }:{
      environment.systemPackages = [
        pkgs.ipfetch
        pkgs.podman
      ];
      homebrew = {
        enable = true;
        casks = [
          "balenaetcher"
          "calibre"
          "discord"
          "docker-desktop"
          "duckduckgo"
          "fuse-t"
          "google-chrome"
          "proton-drive"
          "proton-mail"
          "proton-pass"
          "protonvpn"
          "qbittorrent"
          "shortcat"
          "telegram"
          "tradingview"
          "veracrypt-fuse-t"
          "visual-studio-code@insiders"
          "whatsApp"
        ];
        brews = [
          "talosctl"
        ];
        masApps = {
          "Perplexity ask anything" = 6714467650;
          "HP Smart" = 1474276998;
        };
        onActivation.cleanup = "zap";
      };
      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Brave Browser.app"
          "/Applications/Warp.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "/Applications/qbittorrent.app"
          "/Applications/Telegram.app"
          "/Applications/WhatsApp.app"
          "/Applications/Discord.app"
          "/Applications/Proton Mail.app"
          "/System/Applications/Automator.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Utilities/Activity Monitor.app"
        ];
      };
      nixpkgs.hostPlatform = "aarch64-darwin";
    };

    kyoshiConfiguration = { pkgs, ... }:{
      environment.systemPackages = [
      ];
      homebrew = {
        enable = true;
        casks = [
          "google-chrome"
          "proton-drive"
        ];
        brews = [
        ];
        masApps = {
          "HP Smart" = 1474276998;
        };
        taps = [
        ];
        onActivation.cleanup = "zap";
      };
      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Brave Browser.app"
          "/Applications/Warp.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "/System/Applications/Automator.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Utilities/Activity Monitor.app"
        ];
        loginwindow = {
          GuestEnabled = false;
          SHOWFULLNAME = false;
        };
      };
      nixpkgs.hostPlatform = "x86_64-darwin";
    };

    defaultHomebrewModule = {
      nix-homebrew = {
        enable = true;
        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;
        # User owning the Homebrew prefix
        user = "adrianofsantos";
        autoMigrate = true;
      };
    };
    kyoshiHomebrewModule = {
      nix-homebrew = {
        enable = true;
        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = false;
        # User owning the Homebrew prefix
        user = "adrianofsantos";
        autoMigrate = true;
      };
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Aang
    darwinConfigurations."Aang" = nix-darwin.lib.darwinSystem {
      modules = [ 
        commonConfiguration
        personalConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        defaultHomebrewModule
        ./modules/proton.nix
      ];
    };
    # $ darwin-rebuild build --flake .#kyoshi
    darwinConfigurations."kyoshi" = nix-darwin.lib.darwinSystem {
      modules = [ 
        commonConfiguration
        kyoshiConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        kyoshiHomebrewModule
      ];
    };
  };
}
