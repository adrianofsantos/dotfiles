{ ... }:

{
  nix = {
    enable = true;
    settings = {
      experimental-features = "nix-command flakes";
    };
    optimise = {
      automatic = true;
      interval = [{ Hour = 6; Minute = 0; }];
    };
    gc = {
      automatic = true;
      options = "--delete-older-than 7d";
    };
  };
}
