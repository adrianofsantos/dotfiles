{ ... }:

{
  homebrew{
    casks = [
    ];
    brews = [
    ];
    taps = [
    ];
    masApps = {
      "GarageBand" = 682658836;
      "iMovie" = 408981434;
      "Keynote" = 409183694;
      "Numbers" = 409203825;
      "Pages" = 409201541;
    };
  };

  system.defaults.dock.persistent-apps = [
    "/Applications/Brave Browser.app"
    "/Applications/Warp.app"
    "/Applications/Obsidian.app"
    "/Applications/Telegram.app"
    "/Applications/WhatsApp.app"
    "/Applications/Proton Mail.app"
    "/System/Applications/Automator.app"
    "/System/Applications/Calendar.app"
    "/System/Applications/Utilities/Activity Monitor.app"
  ];
}
