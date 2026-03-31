{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    ipfetch
  ];

  homebrew = {
    casks = [
      "claude"
      "claude-code"
      "discord"
      "fuse-t"
      "proton-drive"
      "proton-mail"
      "proton-pass"
      "protonvpn"
      "telegram"
      "vlc"
      "whatsApp"
    ];
    brews = [
      "talosctl"
    ];
    masApps = {
      "Perplexity ask anything" = 6714467650;
    };
  };
}
