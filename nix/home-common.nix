{ config, pkgs, user, ... }:

let
  cryptomator-cli = pkgs.stdenv.mkDerivation rec {
    pname = "cryptomator-cli";
    version = "0.6.1";
    src = pkgs.fetchzip {
      url = "https://github.com/cryptomator/cli/releases/download/${version}/cryptomator-cli-${version}-mac-arm64.zip";
      sha256 = "sha256-wtaqTlU+NVR6Qg/8mXkN96LB1S6IiGrLDVzuyxTNeSs=";
      stripRoot = false;
    };
    dontBuild = true;
    installPhase = ''
      mkdir -p $out/Applications
      cp -r cryptomator-cli.app $out/Applications/

      mkdir -p $out/bin
      cat > $out/bin/cryptomator-cli << EOF
      #!/bin/sh
      exec "$out/Applications/cryptomator-cli.app/Contents/MacOS/cryptomator-cli" "\$@"
      EOF
      chmod +x $out/bin/cryptomator-cli
    '';
  };
in
{
  home.username = user.username;
  home.homeDirectory = user.homeDir;
  home.stateVersion = "24.05";

  home.packages = with pkgs; [
    cryptomator-cli
    eza
    fastfetch
    fd
    fzf
    gitleaks
    jq
    krew
    kubecolor
    kubectx
    lazygit
    neovim
    ripgrep
    tree
    wget
  ];

  programs.zsh = {
    enable = true;

    shellAliases = {
      # Kubernetes
      k = "kubectl";
      kctx = "kubectx";
      kns = "kubens";

      # ls → eza
      ls = "eza --icons";
      l = "ls --git -l";
      lt = "l --tree --level=2";
      la = "l -a";

      # cat → bat
      cat = "bat";

      # Atalhos
      v = "nvim";
      lg = "lazygit";

      # Git
      g = "git";
      ga = "git add";
      gc = "git commit";
      gca = "git commit --amend";
      gcan = "git commit --amend --no-edit";
      gco = "git checkout";
      gcp = "git cherry-pick";
      gd = "git diff";
      gds = "git diff --staged";
      gl = "git log --oneline --graph --decorate -20";
      gp = "git push";
      gpl = "git pull";
      gb = "git branch";
      gsw = "git switch";
      gsc = "git switch -c";
      gst = "git stash";
      gstp = "git stash pop";
      grb = "git rebase";
      grbi = "git rebase -i";
      gs = "git status";

      # Nix
      dr = "sudo darwin-rebuild switch --flake ~/repos/github/dotfiles/nix/";

      # Navegação
      ".." = "cd ..";
      "..." = "cd ../..";
      "...." = "cd ../../..";
      "....." = "cd ../../../..";
      "......" = "cd ../../../../..";
    };

    initContent = ''
      # Suffix aliases — abrir arquivos diretamente no nvim
      alias -s txt=nvim
      alias -s md=nvim
      alias -s yaml=nvim
      alias -s yml=nvim
      alias -s json=nvim

      # gitignore.io helper
      function gi() { curl -sLw "\n" https://www.toptal.com/developers/gitignore/api/$@ ;}
    '';

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIX_CONF_DIR = "$HOME/.config/nix";
    };
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  programs.git = {
    enable = true;
    signing = {
      key = user.gpgKey;
      signByDefault = true;
    };
    settings = {
      user.name = user.fullName;
      user.email = user.email;
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  programs.gpg = {
    enable = true;
  };

  services.gpg-agent = {
    enable = true;
    pinentryPackage = pkgs.pinentry_mac;
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/starship.toml";
  };

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin-frappe";
    syntaxes = {};
  };
  xdg.configFile."bat/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/bat/themes";
  };

  xdg.configFile."bpytop" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/bpytop";
  };

  xdg.configFile."raycast" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/raycast";
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/nvim";
  };

  home.file.".claude/statusline-command.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/statusline-command.sh";
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/settings.json";
  };
}
