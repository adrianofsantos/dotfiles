{
  description = "My nix-darwin system flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin.url = "github:LnL7/nix-darwin";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";
    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, nix-homebrew }:
  let
    configuration = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;

      # List packages installed in system profile. To search by name, run:
      # $ nix-env -qaP | grep wgepkgs.wgett
      environment.systemPackages =
        [
          pkgs.ansible
          pkgs.bat
          pkgs.eza
          pkgs.fd
          pkgs.fzf
          pkgs.htop
          pkgs.imagemagick
          pkgs.ipcalc
          pkgs.ipfetch
          pkgs.jq
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
          appcleaner
          balenaetcher
          ccleaner
          discord
          #Firefox # Download manual
          #google-chrome # Download manual
          #microsoft-edge # Download manual
          ollama
          telegram
          #warp
          whatsapp
        ];
        brews = [
          "bpytop"
          "watch"
        ];
        onActivation.cleanup = "zap";
        onActivation.autoUpdate = true;
        onActivation.upgrade = true;
      };

      system.defaults = {
        dock.autohide = true;
        dock.autohide-delay = 0.25;
        dock.persistent-apps = [
          "/Applications/Firefox.app"
          "/Applications/Warp.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
          "/Applications/qbittorrent.app"
          "/Applications/Telegram.app"
          "/Applications/WhatsApp.app"
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

      security.pam.enableSudoTouchIdAuth = true;

      nix.useDaemon = true;

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
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#Aang
    darwinConfigurations."Aang" = nix-darwin.lib.darwinSystem {
      modules = [ 
        configuration
        nix-homebrew.darwinModules.nix-homebrew {
          nix-homebrew = {
            enable = true;
            # Apple Silicon Only: Also install Homebrew under the default Intel prefix for Rosetta 2
            enableRosetta = true;
            # User owning the Homebrew prefix
            user = "adrianofsantos";
            autoMigrate = true;
          };
        }
      ];
    };
  };
}
