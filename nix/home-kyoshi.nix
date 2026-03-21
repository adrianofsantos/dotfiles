{ pkgs, lib, ... }:

{
  imports = [ ./home-common.nix ];

  home.packages = with pkgs; [
    lazydocker
  ];

  programs.zsh.initContent = lib.mkAfter ''
    # Docker CLI completions
    fpath=(/Users/adrianofsantos/.docker/completions $fpath)
    autoload -Uz compinit
    compinit
  '';
}
