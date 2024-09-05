{
  config, pkgs, ...
}:
{
  imports = [
    ./modules/satisfactory-server.nix
  ];
  environment.systemPackages = with pkgs; [
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
  ];

  time.timeZone = "Europe/Helsinki";
  i18n.defaultLocale = "en_US.UTF-8";
  console.keyMap = "fi";

  services.ntp.enable = true;
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
  services.redis.servers."".enable = true;
  services.ntopng = {
    enable = true;
    extraConfig = ''
        --data-dir /var/lib/ntopng
	--user ntopng
	--interface any
	--http-port 3000
	--http-address 0.0.0.0
    '';
  };

  nix = {
    package = pkgs.nixFlakes;
    extraOptions = ''
      experimental-features = nix-command flakes
    '';
  };
  system.stateVersion = "24.05";
}

