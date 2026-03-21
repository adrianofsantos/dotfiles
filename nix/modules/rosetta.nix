{ pkgs, ... }:

{
  nix-homebrew = {
    enable = true;
    enableRosetta = pkgs.stdenv.hostPlatform.isAarch64;
    user = "adrianofsantos";
    autoMigrate = true;
  };
}
