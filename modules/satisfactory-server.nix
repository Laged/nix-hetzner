{ config, pkgs, lib, ... }:
let
  cfg = config.services.satisfactory;
  workingDirectory = cfg.workingDirectory;
  gameInstallDir = "${workingDirectory}/SatisfactoryDedicatedServer";
  gameConfigDir = "${gameInstallDir}/FactoryGame/Saved/Config/LinuxServer";
  steamCmd = "${pkgs.steamcmd}/bin/steamcmd";
  crudini = "${pkgs.crudini}/bin/crudini";
in
{
  options.services.satisfactory = {
    enable = lib.mkEnableOption "Enable Satisfactory Dedicated Server";

    beta = lib.mkOption {
      type = lib.types.enum [ "public" "experimental" ];
      default = "public";
      description = "Beta channel to follow";
    };

    address = lib.mkOption {
      type = lib.types.str;
      default = "0.0.0.0";
      description = "Bind address";
    };

    maxPlayers = lib.mkOption {
      type = lib.types.number;
      default = 8;
      description = "Number of players";
    };

    tickRate = lib.mkOption {
      type = lib.types.number;
      default = 60;
      description = "Max tick rate";
    };

    autoPause = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto pause when no players are online";
    };

    autoSaveOnDisconnect = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Auto save on player disconnect";
    };

    extraSteamCmdArgs = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "Extra arguments passed to steamcmd command";
    };

    workingDirectory = lib.mkOption {
      type = lib.types.str;
      default = "/var/lib/satisfactory";
      description = "Working directory for the Satisfactory server";
    };
  };

  config = lib.mkIf cfg.enable {
    users.users.satisfactory = {
      home = workingDirectory;
      createHome = true;
      isSystemUser = true;
      group = "satisfactory";
    };
    users.groups.satisfactory = { };
    nixpkgs.config.allowUnfree = true;

    networking.firewall = {
      allowedTCPPorts = [ 7777 ];
      allowedUDPPorts = [ 7777 ];
    };

    # Define systemd service with proper pre-start for autoupdate
    systemd.services.satisfactory = {
      wantedBy = [ "multi-user.target" ];
      preStart = ''
        set -e  # Exit on error
        set -x  # Enable shell debugging

        # Ensure the working directory is owned by 'satisfactory'
        chown -R satisfactory:satisfactory "${workingDirectory}"

        # Run steamcmd as 'satisfactory' user
        ${steamCmd} \
          +force_install_dir "${gameInstallDir}" \
          +login anonymous \
          +app_update 1690800 -beta ${cfg.beta} validate \
          +quit

        # Check if steamcmd succeeded
        if [ $? -ne 0 ]; then
          echo "steamcmd failed to update the server."
          exit 1
        fi

        # Patch to make it runnable on NixOS
        ${pkgs.patchelf}/bin/patchelf \
          --set-interpreter ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 \
          "${gameInstallDir}/Engine/Binaries/Linux/FactoryServer-Linux-Shipping"

        # Set up paths
        ln -sfv "${workingDirectory}/.steam/steam/linux64" "${workingDirectory}/.steam/sdk64"
        mkdir -p "${gameConfigDir}"

        # Patch config files based on options
        ${crudini} --set "${gameConfigDir}/Game.ini" '/Script/Engine.GameSession' MaxPlayers ${toString cfg.maxPlayers}
        ${crudini} --set "${gameConfigDir}/ServerSettings.ini" '/Script/FactoryGame.FGServerSubsystem' mAutoPause ${if cfg.autoPause then "True" else "False"}
        ${crudini} --set "${gameConfigDir}/ServerSettings.ini" '/Script/FactoryGame.FGServerSubsystem' mAutoSaveOnDisconnect ${if cfg.autoSaveOnDisconnect then "True" else "False"}

        # Set the engine settings
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/OnlineSubsystemUtils.IpNetDriver' NetServerMaxTickRate ${toString cfg.tickRate}
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/OnlineSubsystemUtils.IpNetDriver' LanServerMaxTickRate ${toString cfg.tickRate}
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/SocketSubsystemEpic.EpicNetDriver' NetServerMaxTickRate ${toString cfg.tickRate}
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/SocketSubsystemEpic.EpicNetDriver' LanServerMaxTickRate ${toString cfg.tickRate}
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.Engine' NetClientTicksPerSecond ${toString cfg.tickRate}
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.Player' ConfiguredInternetSpeed 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.Player' ConfiguredLanSpeed 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/OnlineSubsystemUtils.IpNetDriver' MaxClientRate 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/OnlineSubsystemUtils.IpNetDriver' MaxInternetClientRate 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/SocketSubsystemEpic.EpicNetDriver' MaxClientRate 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/SocketSubsystemEpic.EpicNetDriver' MaxInternetClientRate 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.GameNetworkManager' TotalNetBandwidth 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.GameNetworkManager' MaxDynamicBandwidth 104857600
        ${crudini} --set "${gameConfigDir}/Engine.ini" '/Script/Engine.GameNetworkManager' MinDynamicBandwidth 10485760

        # Readjust ownership
        chown -R satisfactory:satisfactory "${workingDirectory}"
      '';

      # Start the server
      script = ''
        "${gameInstallDir}/FactoryServer.sh"
      '';
      # Keep it running with systemd
      serviceConfig = {
        Restart = "always";
        User = "satisfactory";
        Group = "satisfactory";
        WorkingDirectory = "${workingDirectory}";
        TimeoutStartSec = 600;
      };
      # Make sure environment vars are OK
      environment = {
        SSL_CERT_FILE = "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt";
        LD_LIBRARY_PATH = "${gameInstallDir}/linux64:${gameInstallDir}/Engine/Binaries/Linux:${gameInstallDir}/Engine/Binaries/ThirdParty/PhysX3/Linux/x86_64-unknown-linux-gnu";
      };
    };
  };
}

