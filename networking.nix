{
  configs, pkgs, ...
}:
{
  networking = {
    hostName = "nixtu";
    useDHCP = false;
    networkmanager.enable = false;
    nameservers = [ "1.1.1.1" ];
    firewall = {
      enable = true;
      allowPing = true;
      allowedTCPPorts = [ 22 3000 ];
    };
  };
  systemd.network = {
    enable = true;
    networks = {
      "30-wan" = {
        matchConfig = {
           Name = "ens4";
        };
        DHCP = "yes";
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
    };
  };
}
