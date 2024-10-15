{ config, pkgs, ... }:
{
  imports = [ ./modules/satisfactory-server.nix ];
  environment.systemPackages = with pkgs; [
    btop
    vim
    helix
    git
    wget
    curl
    gawk
    lsof
    unixtools.netstat
    kitty
    mtr
    steamcmd
  ];

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fi";

  services.satisfactory = {
    enable = true;
    beta = "public";
    address = "0.0.0.0";
    maxPlayers = 8;
    tickRate = 60;
    autoPause = true;
    autoSaveOnDisconnect = true;
    extraSteamCmdArgs = "";
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = "24.05";
}
