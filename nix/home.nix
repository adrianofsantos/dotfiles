{ config, pkgs, ... }:

let
  dotfilesPath = "/Users/adrianofsantos/repos/github/dotfiles";
in
{
  home.username = "adrianofsantos";
  home.homeDirectory = "/Users/adrianofsantos";
  home.stateVersion = "24.05";

  # --- User packages (migrados de environment.systemPackages) ---
  home.packages = with pkgs; [
    # bat, starship e zoxide são instalados via programs.* abaixo
    bpytop
    eza
    fastfetch
    fd
    fzf
    gitleaks
    jq
    krew
    kubecolor
    kubectx
    lazydocker
    lazygit
    neovim
    ripgrep
    tree
    wget
  ];

  # --- ZSH (migrado de zsh/.zshrc + aliases.zsh + functions.zsh) ---
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

      # Docker CLI completions
      fpath=(/Users/adrianofsantos/.docker/completions $fpath)
      autoload -Uz compinit
      compinit
    '';

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIX_CONF_DIR = "$HOME/.config/nix";
    };
  };

  # --- Zoxide ---
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };

  # --- Git ---
  programs.git = {
    enable = true;
    userName = "Adriano Santos";
    userEmail = "adriano@sotnas.net";
    signing = {
      key = "16D7D0D901DE83FB";
      signByDefault = true;
    };
    extraConfig = {
      init.defaultBranch = "main";
      pull.rebase = true;
      push.autoSetupRemote = true;
      core.editor = "nvim";
    };
  };

  # --- Starship (migrado de starship.toml) ---
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/starship.toml";
  };

  # --- Bat (migrado de bat/) ---
  programs.bat = {
    enable = true;
    config = {
      theme = "Catppuccin-frappe";
    };
    syntaxes = {};
  };
  xdg.configFile."bat/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/bat/themes";
  };

  # --- Bpytop ---
  xdg.configFile."bpytop" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/bpytop";
  };

  # --- Raycast (sem extensions/ — está no .gitignore) ---
  xdg.configFile."raycast" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/raycast";
  };

  # --- Neovim (manter LazyVim como está, só referenciar a pasta) ---
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "${dotfilesPath}/nvim";
  };

  # --- Claude Code ---
  home.file.".claude/statusline-command.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/claude/statusline-command.sh";
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/claude/settings.json";
  };
}
