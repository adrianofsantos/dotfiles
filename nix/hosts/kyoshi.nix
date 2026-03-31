{ ... }:

{
  homebrew = {
    casks = [
      "android-studio"
      "balenaetcher"
      "calibre"
      "docker-desktop"
      "obs"
      "ollama-app"
      "proton-drive"
      "qbittorrent"
      "samsung-magician"
      "steam"
      "tradingview"
      "veracrypt-fuse-t"
    ];
    brews = [
      "gemini-cli"
      "irssi"
      "opentofu"
      "talhelper"
      "xcodegen"
    ];
    masApps = {
      "Xcode" = 497799835;
    };
    taps = [
    ];
  };

  system.defaults = {
    dock.persistent-apps = [
      "/Applications/Brave Browser.app"
      "/Applications/Warp.app"
      "/Applications/Obsidian.app"
      "/Applications/qbittorrent.app"
      "/Applications/Telegram.app"
      "/Applications/WhatsApp.app"
      "/Applications/Discord.app"
      "/Applications/Proton Mail.app"
      "/System/Applications/Automator.app"
      "/System/Applications/Calendar.app"
      "/System/Applications/Utilities/Activity Monitor.app"
      "/System/Applications/System Settings.app"
    ];
    loginwindow.SHOWFULLNAME = false;
  };
}
