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
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wgepkgs.wgett
      environment.systemPackages = [
        pkgs.ansible
        pkgs.bat
        pkgs.eza
        pkgs.fd
        pkgs.fzf
        pkgs.gitleaks
        pkgs.gnupg
        pkgs.htop
        pkgs.imagemagick
        pkgs.ipcalc
        pkgs.ipfetch
        pkgs.jq
        pkgs.lazydocker
        pkgs.lazygit
        pkgs.neofetch
        pkgs.neovim
        pkgs.obsidian
        pkgs.ripgrep
        pkgs.starship
        pkgs.stow
        pkgs.tree
        pkgs.wget
      ];

      homebrew = {
        enable = true;
        casks = [
          "appcleaner"
          "balenaetcher"
          "ccleaner"
          "discord"
          "duckduckgo"
          "Firefox"
          #"google-chrome"
          "microsoft-edge"
          "ollama"
          "openmtp"
          "proton-drive"
          "proton-mail"
          "proton-pass"
          "protonvpn"
          "qbittorrent"
          "raycast"
          "telegram"
          "tradingview"
          "warp"
          "visual-studio-code@insiders"
          "whatsapp"
        ];
        brews = [
          "bpytop"
          "watch"
          "mas"
        ];
        masApps = {
          "Perplexity ask anything" = 6714467650;
        };
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = false;
        onActivation.upgrade = false;
      };

      system.defaults = {
        dock.autohide = true;
        dock.autohide-delay = 0.25;
        dock.persistent-apps = [
          "/Applications/Microsoft Edge.app"
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
      nixpkgs.hostPlatform = "aarch64-darwin";
    };

    homebrewModule = {
      nix-homebrew = {
        enable = true;
        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = true;
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
        nix-homebrew.darwinModules.nix-homebrew homebrewModule
      ];
    };
  };
}
