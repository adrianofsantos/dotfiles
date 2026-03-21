{ ... }:

{
  homebrew.casks = [
    "chatgpt"
    "google-chrome"
  ];

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
