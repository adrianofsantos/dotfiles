{ lib, ... }:

{
  # Desativa App Nap para ProtonVPN e ProtonDrive — evita que o macOS
  # suspenda os processos em background em máquinas com menos recursos.
  # Os apps gerenciam seu próprio auto-start via Login Items do macOS.
  system.activationScripts.protonAppNap.text = ''
    /usr/bin/defaults write ch.protonvpn.mac NSAppSleepDisabled -bool YES
    /usr/bin/defaults write me.proton.drive NSAppSleepDisabled -bool YES
  '';
}

