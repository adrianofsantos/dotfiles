{ ... }:

{
  system.defaults = {
    dock.autohide = true;
    dock.autohide-delay = 0.25;
    finder.AppleShowAllExtensions = true;
    finder.FXPreferredViewStyle = "clmv";
    screencapture.target = "file";
    screencapture.location = "~/Pictures/screenshots";
    screensaver.askForPasswordDelay = 10;
    loginwindow.LoginwindowText = "\u201cSeja a mudança que você quer ver no mundo.\u201d \u2013 Mahatma Gandhi";
    loginwindow.GuestEnabled = false;
    menuExtraClock.Show24Hour = true;
    menuExtraClock.ShowDate = 0;
  };

  security.pam.services.sudo_local.touchIdAuth = true;
}
