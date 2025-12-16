{ lib, ... }:

{
  # 🔋 Mata o App Nap de vez
  system.activationScripts.protonAppNap.text = ''
    /usr/bin/defaults write ch.protonvpn.mac NSAppSleepDisabled -bool YES
    /usr/bin/defaults write me.proton.drive NSAppSleepDisabled -bool YES
  '';

  # 🚀 LaunchAgents — nível usuário (onde Electron funciona direito)
  launchd.user.agents.protonvpn = {
    serviceConfig = {
      Label = "ch.protonvpn.mac";
      ProgramArguments = [
        "/Applications/ProtonVPN.app/Contents/MacOS/ProtonVPN"
      ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      ProcessType = "Interactive";
    };
  };

  launchd.user.agents.protondrive = {
    serviceConfig = {
      Label = "me.proton.drive";
      ProgramArguments = [
        "/Applications/Proton Drive.app/Contents/MacOS/Proton Drive"
      ];
      RunAtLoad = true;
      KeepAlive = {
        SuccessfulExit = false;
        Crashed = true;
      };
      ProcessType = "Interactive";
    };
  };
}

