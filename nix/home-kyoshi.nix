{ pkgs, lib, ... }:

{
  imports = [ ./home-common.nix ];

  home.packages = with pkgs; [
    lazydocker
  ];

  # Regenera o completion do Docker CLI a partir do binário real (Homebrew
  # cask), evitando depender do Docker Desktop escrever isso sozinho fora do
  # Nix. command -v evita falha se o cask ainda não tiver sido instalado
  # neste mesmo `dr` (resolve sozinho no próximo).
  home.activation.dockerCompletions = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    if [[ -v DRY_RUN ]]; then
      _i "Would regenerate $HOME/.docker/completions/_docker"
    elif command -v docker >/dev/null 2>&1; then
      mkdir -p "$HOME/.docker/completions"
      docker completion zsh > "$HOME/.docker/completions/_docker"
    fi
  '';

  programs.zsh.initContent = lib.mkAfter ''
    # Docker CLI completions
    fpath=(/Users/adrianofsantos/.docker/completions $fpath)

    autoload -Uz compinit
    compinit
  '';
}
