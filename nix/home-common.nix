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
      dr-check = "nix flake check ~/repos/github/dotfiles/nix/";
      dr-build = "sudo darwin-rebuild build --flake ~/repos/github/dotfiles/nix/";

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

      # Builda, mostra o changelog do nix-darwin e o diff de pacotes contra a
      # geração ativa, sem ativar nada. Roda `dr` manualmente depois pra confirmar.
      function dr-review() {
        (
          cd ~/repos/github/dotfiles || return 1
          sudo darwin-rebuild build --flake ~/repos/github/dotfiles/nix/ || return 1
          echo
          echo "--- darwin-changes ---"
          bat --paging=never result/darwin-changes
          echo
          echo "--- diff-closures (geração ativa -> result) ---"
          nix store diff-closures /run/current-system ./result
        )
      }
    '';

    sessionVariables = {
      EDITOR = "nvim";
      VISUAL = "nvim";
      NIX_CONF_DIR = "$HOME/.config/nix";
    };

    autosuggestion = {
      enable = true;
      # match_prev_cmd, depois history — usado como fallback: o atuin
      # (initContent em mkOrder 1000, depois do mkOrder 700 daqui) se
      # prepende sozinho como primeira estratégia ao inicializar
      # (crates/atuin/src/shell/atuin.zsh, incondicional). Ordem final:
      # ZSH_AUTOSUGGEST_STRATEGY=(atuin match_prev_cmd history).
      strategy = [ "match_prev_cmd" "history" ];
    };

    # highlighter "main" (default) colore comando válido no PATH de verde
    # e inválido/typo de vermelho. mkOrder 1200, sourced por último — depois
    # de autosuggestion (700) e do initContent do atuin (1000), como exigido
    # pelo próprio zsh-syntax-highlighting.
    syntaxHighlighting.enable = true;
  };

  programs.atuin = {
    enable = true;
    enableZshIntegration = true;
    # Sem --disable-up-arrow nem --disable-ctrl-r: atuin assume os dois binds.
    daemon.enable = true;

    settings = {
      search_mode = "daemon-fuzzy";
      daemon.autostart = true;

      # Fase 1: só local. Fase 2 (sync self-hosted) muda apenas isto:
      #   auto_sync = true;
      #   sync_address = "https://<host self-hosted>";
      #   dotfiles.enabled = true; (se for usar sync de dotfiles do atuin)
      auto_sync = false;

      workspaces = true;
      enter_accept = true;
      store_failed = true;

      history_filter = [
        # "^secret-cmd"
        # "^innocuous-cmd .*--secret=.+"
      ];
      cwd_filter = [
        # "^/very/secret/area"
      ];

      ui.columns = [ "duration" "time" "host" "command" ];
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
    hooks = {
      pre-commit = ./git-hooks/pre-commit;
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  xdg.configFile."starship.toml" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/starship.toml";
    force = true;
  };

  programs.bat = {
    enable = true;
    config.theme = "Catppuccin-frappe";
    syntaxes = {};
  };
  xdg.configFile."bat/themes" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/bat/themes";
    force = true;
  };

  xdg.configFile."bpytop" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/bpytop";
    force = true;
  };

  xdg.configFile."raycast" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/raycast";
    force = true;
  };

  xdg.configFile."nvim" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/nvim";
    force = true;
  };

  home.file.".claude/CLAUDE.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/CLAUDE.md";
    force = true;
  };
  home.file.".claude/skills/prd-spec-code-workflow/SKILL.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/skills/prd-spec-code-workflow/SKILL.md";
    force = true;
  };
  home.file.".claude/skills/verify/SKILL.md" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/skills/verify/SKILL.md";
    force = true;
  };
  home.file.".claude/statusline-command.sh" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/statusline-command.sh";
    force = true;
  };
  home.file.".claude/settings.json" = {
    source = config.lib.file.mkOutOfStoreSymlink "${user.dotfilesDir}/claude/settings.json";
    force = true;
  };
}
