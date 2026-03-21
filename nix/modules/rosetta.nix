{ pkgs, user, ... }:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
    user = user.username;
    autoMigrate = true;
  };
}
