{ config, pkgs, ... }:

{
  home.username = "adrianofsantos";
  home.homeDirectory = "/Users/adrianofsantos";
  home.stateVersion = "24.05";

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

    initExtra = ''
      # Suffix aliases — abrir arquivos diretamente no nvim
      alias -s txt=nvim
      alias -s md=nvim
      alias -s yaml=nvim
      alias -s yml=nvim
      alias -s json=nvim

      # Starship prompt
      eval "$(starship init zsh)"

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

  # --- Neovim (manter LazyVim como está, só referenciar a pasta) ---
  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink
      "/Users/adrianofsantos/repos/github/dotfiles/nvim";
  };
}
