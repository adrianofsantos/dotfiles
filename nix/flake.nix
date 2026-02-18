{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-25.05-darwin";
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-25.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  #outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, homebrew-bundle }:
  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew, home-manager }:
  let
    commonConfiguration = { pkgs, ... }: {
      system.primaryUser = "adrianofsantos";
      users.users.adrianofsantos.home = "/Users/adrianofsantos";
      nixpkgs.config.allowUnfree = false;
      # Fonts
      fonts.packages = with pkgs; [
        nerd-fonts.hack
      ];
      # System-level packages (available to all users)
      environment.systemPackages = [
        pkgs.gcal
        pkgs.gnupg
        pkgs.htop
        pkgs.imagemagick
        pkgs.ipcalc
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

      nix = {
        settings = {
          # Necessary for using flakes on this system.
          experimental-features = "nix-command flakes";
        };

        optimise = {
          automatic = true;
          interval = [
            {
              Hour = 6;
              Minute = 0;
            }
          ];
        };

        gc = {
          automatic = true;
          options = "--delete-older-than 7d";
        };
      };

      # Enable alternative shell support in nix-darwin.
      # programs.fish.enable = true;

      # Set Git commit hash for darwin-version.
      system.configurationRevision = self.rev or self.dirtyRev or null;

      # Used for backwards compatibility, please read the changelog before changing.
      # $ darwin-rebuild changelog
      system.stateVersion = 5;
    };

    personalConfiguration = { pkgs, ... }:{
      environment.systemPackages = [
        pkgs.ipfetch
        pkgs.podman
      ];
      homebrew = {
        enable = true;
        casks = [
          "claude"
          "claude-code"
          "fuse-t"
          "proton-drive"
          "proton-mail"
          "proton-pass"
          "protonvpn"
          "telegram"
          "veracrypt-fuse-t"
          "vlc"
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
    };

    aangConfigurations = { pkgs, ... }:{
      nixpkgs.hostPlatform = "aarch64-darwin";
      homebrew = {
        enable = true;
        casks = [
          "chatgpt"
          "google-chrome"
        ];
      };
      system.defaults = {
        dock.persistent-apps = [
          "/Applications/Brave Browser.app"
          "/Applications/Warp.app"
          "/Applications/Obsidian.app"
          "/Applications/Telegram.app"
          "/Applications/WhatsApp.app"
          "/Applications/Proton Mail.app"
          "/System/Applications/Automator.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Utilities/Activity Monitor.app"
        ];
      };
    };

    kyoshiConfiguration = { pkgs, ... }:{
      environment.systemPackages = [
      ];
      homebrew = {
        enable = true;
        casks = [
          "balenaetcher"
          "calibre"
          "discord"
          "docker-desktop"
          "ollama-app"
          "proton-drive"
          "qbittorrent"
          "samsung-magician"
          "steam"
          "tradingview"
          "visual-studio-code"
        ];
        brews = [
          "gemini-cli"
          "irssi"
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
          "/Applications/Obsidian.app"
          "/Applications/qbittorrent.app"
          "/Applications/Telegram.app"
          "/Applications/WhatsApp.app"
          "/Applications/Discord.app"
          "/Applications/Proton Mail.app"
          "/System/Applications/Automator.app"
          "/System/Applications/Calendar.app"
          "/System/Applications/Utilities/Activity Monitor.app"
          "/System/Applications/System Settings.app"
        ];
        loginwindow = {
          GuestEnabled = false;
          SHOWFULLNAME = false;
        };
        screensaver.askForPasswordDelay = 10;
      };
      nixpkgs.hostPlatform = "aarch64-darwin";
    };

    rosettaHomebrewModule = {pkgs, ...}: {
      nix-homebrew = {
        enable = true;
        # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
        enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
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
        aangConfigurations
        nix-homebrew.darwinModules.nix-homebrew
        rosettaHomebrewModule
        ./modules/proton.nix
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.adrianofsantos = import ./home.nix;
          };
        }
      ];
    };
    # $ darwin-rebuild build --flake .#Kyoshi
    darwinConfigurations."Kyoshi" = nix-darwin.lib.darwinSystem {
      modules = [
        commonConfiguration
        personalConfiguration
        kyoshiConfiguration
        nix-homebrew.darwinModules.nix-homebrew
        rosettaHomebrewModule
        home-manager.darwinModules.home-manager
        {
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            users.adrianofsantos = import ./home.nix;
          };
        }
      ];
    };
  };
}
