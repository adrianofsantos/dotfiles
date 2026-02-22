{ config, pkgs, ... }:

{
  home.username = "adrianofsantos";
  home.homeDirectory = "/Users/adrianofsantos";
  home.stateVersion = "24.05";

  # --- User packages (migrados de environment.systemPackages) ---
  home.packages = with pkgs; [
    bat
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
    starship
    tree
    wget
    zoxide
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
      gc = "git commit";
      gco = "git checkout";
      ga = "git add";

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

      # Zoxide
      eval "$(zoxide init zsh)"

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
      "/Users/adrianofsantos/repos/github/dotfiles/starship.toml";
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
      "/Users/adrianofsantos/repos/github/dotfiles/bat/themes";
  };

  # --- Bpytop (migrado de bpytop/) ---
  xdg.configFile."bpytop" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/bpytop";
  };

  # --- Alacritty (migrado de alacritty/) ---
  xdg.configFile."alacritty" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/alacritty";
  };

  # --- Raycast (sem extensions/ — está no .gitignore) ---
  xdg.configFile."raycast" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/raycast";
  };

  # --- Neovim (manter LazyVim como está, só referenciar a pasta) ---
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/nvim";
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
